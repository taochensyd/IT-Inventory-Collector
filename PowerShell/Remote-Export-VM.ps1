# Define variables
$Servers = @("Server24", "H10", "H04")
$VMNames = @("AD01", "Server17 (SEP)")
$ExportDate = (Get-Date).ToString("yyyyMMdd")
$ExportPath = "\\h14-upjohn1\Hyper-V\Exported VM\$ExportDate"

# Create a PSCredential object with the specified username and password
$username = "hpadmin3"
$password = ConvertTo-SecureString "Mine@Zoom65" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential $username, $password

# Enable CredSSP authentication on the client
Enable-WSManCredSSP -Role Client -DelegateComputer $Servers -Force

# Display script start time
$ScriptStartTime = Get-Date
Write-Host "Script start time: $ScriptStartTime"

# Loop through each server
foreach ($Server in $Servers) {
    Write-Host "Checking server: $Server"

    # Enable CredSSP authentication on the server
    Invoke-Command -ComputerName $Server -ScriptBlock { Enable-WSManCredSSP -Role Server -Force } -Credential $cred

    # Get all VMs on the server using CredSSP authentication
    $VMs = Invoke-Command -ComputerName $Server -ScriptBlock { Get-VM } -Credential $cred -Authentication Credssp

    # Filter VMs by name
    $VMs = $VMs | Where-Object { $VMNames -contains $_.Name }

    # Loop through each VM
    foreach ($VM in $VMs) {

        # Display loop start time
        $LoopStartTime = Get-Date
        Write-Host "Loop start time: $LoopStartTime"

        $VMName = $VM.Name

        # Export the VM using CredSSP authentication
        Write-Host "Attempting to export VM: $VMName to $ExportPath\$VMName"
        try {
            Invoke-Command -ComputerName $Server -ScriptBlock {
                param($VMName, $ExportPath)
                Export-VM -Name $VMName -Path $ExportPath -ErrorAction Stop
            } -ArgumentList $VMName, "$ExportPath\$VMName" -Credential $cred -Authentication Credssp
        }
        catch {
            Write-Host "Failed to export $VMName. Error: $_"
            continue
        }

        # Once exported, move the .vhdx file to the specified location
        $VHDXPath = "$ExportPath\$VMName\Virtual Hard Disks"
        $VHDXFiles = Get-ChildItem -Path $VHDXPath -Filter "*.vhdx" -ErrorAction SilentlyContinue

        foreach ($file in $VHDXFiles) {
            Write-Host "Moving $($file.FullName) to $ExportPath"
            Move-Item -Path $file.FullName -Destination $ExportPath
        }

        # Remove the directory for the VM
        Write-Host "Removing directory: $ExportPath\$VMName"
        Remove-Item -Path "$ExportPath\$VMName" -Recurse -Force
    }
}
