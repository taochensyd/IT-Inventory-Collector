# Define variables
$Servers = @("SERVER24", "SERVER25", "H02", "H04", "H05", "H10", "H11", "H12", "H16")
$ExportDate = (Get-Date).ToString("yyyyMMdd")
$ExportPath = "\\h14-upjohn1\Hyper-V\Exported VM\$ExportDate"
$username = ""
$password = ""


$VMNames = @("ClockOn", "RDS01", "RDS Gold Disk", "MYOB3", "MYOB", "SERVER17 (SEP)", "HCController", "AD01", "SAP01")


# Create a PSCredential object with the specified username and password
$password = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential $username, $password

# Enable CredSSP authentication on the client
Enable-WSManCredSSP -Role Client -DelegateComputer $Servers -Force

# Display script start time
$ScriptStartTime = Get-Date
Write-Host "Script start time: $ScriptStartTime"

# Loop through each server
foreach ($Server in $Servers) {
    # Enable CredSSP authentication on the server
    Invoke-Command -ComputerName $Server -ScriptBlock { Enable-WSManCredSSP -Role Server -Force } -Credential $cred

    # Get all VMs on the server using CredSSP authentication
    $VMs = Invoke-Command -ComputerName $Server -ScriptBlock { Get-VM } -Credential $cred -Authentication Credssp

    # Filter VMs by name
    $VMs = $VMs | Where-Object { $VMNames -contains $_.Name }

    # Loop through each VM
    foreach ($VM in $VMs) {
        $VMName = $VM.Name

        # Export the VM using CredSSP authentication
        try {
            Invoke-Command -ComputerName $Server -ScriptBlock {
                param($VMName, $ExportPath)
                Export-VM -Name $VMName -Path $ExportPath -ErrorAction Stop
            } -ArgumentList $VMName, "$ExportPath" -Credential $cred -Authentication Credssp
        }
        catch {
            Write-Host "Failed to export $VMName. Error: $_"
            continue
        }

        # Once exported, move the .vhdx file to the specified location
        $VHDXPath = "$ExportPath\$VMName\Virtual Hard Disks"
        $VHDXFiles = Get-ChildItem -Path $VHDXPath -Filter "*.vhdx" -ErrorAction SilentlyContinue

        foreach ($file in $VHDXFiles) {
            Move-Item -Path $file.FullName -Destination $ExportPath
        }

        # Remove the directory for the VM
        Remove-Item -Path "$ExportPath\$VMName" -Recurse -Force
    }
}

$dir = "D:\Hyper-V\Exported VM"
Write-Output "Searching for files in directory: $dir"
$files = Get-ChildItem -Path $dir -Filter *.vhdx -Recurse
Write-Output "Found $($files.Count) files"
$fileNames = $files | ForEach-Object {$_.Name}
$fileCount = @{}
$fileNames | ForEach-Object {$fileCount[$_]++}
$filesToDelete = $fileCount.Keys | Where-Object {$fileCount[$_] -gt 3}
Write-Output "Found $($filesToDelete.Count) files with more than 3 occurrences"
foreach ($file in $filesToDelete) {
    Write-Output "Processing file: $file"
    $filesToKeep = $files | Where-Object {$_.Name -eq $file} | Sort-Object LastWriteTime -Descending | Select-Object -First 3
    Write-Output "Keeping the newest 3 files: $($filesToKeep.Name)"
    $filesToRemove = $files | Where-Object {$_.Name -eq $file} | Where-Object {$_.LastWriteTime -lt $filesToKeep[2].LastWriteTime}
    Write-Output "Removing $($filesToRemove.Count) older files: $($filesToRemove.Name)"
    $filesToRemove | Remove-Item
}

# Delete empty subfolders
$subfolders = Get-ChildItem -Path $dir -Directory -Recurse
foreach ($subfolder in $subfolders) {
    if ((Get-ChildItem -Path $subfolder.FullName).Count -eq 0) {
        Write-Output "Removing empty subfolder: $($subfolder.FullName)"
        Remove-Item -Path $subfolder.FullName
    }
}

# Get the available space on the D: drive in bytes
$availableSpace = (Get-PSDrive D).Free

# Convert 3TB to bytes
$threshold = 3TB

# Check if the available space is less than the threshold
if ($availableSpace -lt $threshold) {
    # Empty the Recycle Bin
    Clear-RecycleBin -Force

    # Display a message indicating that the operation was successful
    Write-Output "Recycle Bin has been emptied because the available space on the D: drive was less than 3TB."
} else {
    # Display a message indicating that the Recycle Bin was not emptied
    Write-Output "Recycle Bin was not emptied because the available space on the D: drive was greater than or equal to 3TB."
}




# Display script end time and total time taken
$ScriptEndTime = Get-Date
Write-Host "Script end time: $ScriptEndTime"
Write-Host "Total time taken: $(($ScriptEndTime-$ScriptStartTime).TotalSeconds) seconds"
