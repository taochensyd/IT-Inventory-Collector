# Get hostname
$hostname = hostname

# Get IP address
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '192.168.0.*' }).IPAddress

# Get computer model
$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
$computerModel = $computerSystem.Model

# Get OS version
$os = Get-WmiObject -Class Win32_OperatingSystem
$osVersion = $os.Version

# Get current logged-on domain username
$username = $computerSystem.UserName

# Get CPU information
$cpu = Get-WmiObject -Class Win32_Processor
$cpuCores = $cpu.NumberOfCores
$cpuThreads = $cpu.ThreadCount
$cpuModel = $cpu.Name
$cpuClockSpeed = $cpu.MaxClockSpeed

# Get RAM information
$ram = Get-WmiObject -Class Win32_PhysicalMemory
$ramSize = 0
foreach ($module in $ram) {
    $ramSize += $module.Capacity / 1GB
}

# Get hard drive information
$diskDrive = Get-PhysicalDisk | Select-Object -First 1
$diskSize = [math]::Round($diskDrive.Size / 1GB)
$diskType = if ($diskDrive.MediaType -eq "HDD") { "HDD" } else { "SSD" }
$diskName = $diskDrive.FriendlyName

# Create JSON object
$jsonObject = @{
    "Hostname" = $hostname;
    "IPAddress" = $ipAddress;
    "ComputerModel" = $computerModel;
    "OSVersion" = $osVersion;
    "Username" = $username;
    "CPU" = @{
        "Cores" = $cpuCores;
        "Threads" = $cpuThreads;
        "Model" = $cpuModel;
        "ClockSpeed" = "$($cpuClockSpeed) MHz"
    };
    "RAM" = @{
        "Size" = "$($ramSize) GB";
        "Modules" = @()
    };
    "Disk" = @{
        "Size" = "$($diskSize) GB";
        "Type" = $diskType;
        "Name" = $diskName
    }
}

# Add RAM module information to JSON object
$i=0;
foreach ($module in $ram) {
    if ($i -lt 4){
        $jsonObject.RAM.Modules += @{
            "Size" = "$($module.Capacity / 1GB) GB";
            "Speed" = "$($module.Speed) MHz";
            "SlotUsed" = $module.DeviceLocator
        }
    }
    else{
        break;
    }
    $i++;
}

# Add placeholders for remaining RAM modules if necessary
while ($i -lt 4){
    $jsonObject.RAM.Modules += @{
            "Size" ="";
            "Speed" ="";
            "SlotUsed" ="";
        }
    $i++;
}

# Convert the JSON object to a string
$jsonString = ConvertTo-Json -InputObject $jsonObject -Depth 3

# Send the JSON object as an HTTP POST request to the specified URI
$uri = "http://192.168.0.165:5566"
Invoke-RestMethod -Method Post -Uri $uri -Body $jsonString -ContentType 'application/json'

# Output all hardware details gathered
Write-Output "`nHardware Details:`n"
Write-Output "`nHostname: $($jsonObject.Hostname)`n"
Write-Output "`nIPAddress: $($jsonObject.IPAddress)`n"
Write-Output "`nComputer Model: $($jsonObject.ComputerModel)`n"
Write-Output "`nOS Version: $($jsonObject.OSVersion)`n"
Write-Output "`nUsername: $($jsonObject.Username)`n"
Write-Output "`nCPU:`n"
Write-Output "`tCores: $($jsonObject.CPU.Cores)`n"
Write-Output "`tThreads: $($jsonObject.CPU.Threads)`n"
Write-Output "`tModel: $($jsonObject.CPU.Model)`n"
Write-Output "`tClock Speed: $($jsonObject.CPU.ClockSpeed)`n"

Write-Output "`nRAM:`n"
Write-Output "`tSize: $($jsonObject.RAM.Size)`n"
foreach ($module in $jsonObject.RAM.Modules) {
    Write-Output "`tModule:`n"
    Write-Output "`t`tSize: $($module.Size)`n"
    Write-Output "`t`tSpeed: $($module.Speed)`n"
    Write-Output "`t`tSlot Used: $($module.SlotUsed)`n"
}

Write-Output "`nDisk:`n"
Write-Output "`tSize: $($jsonObject.Disk.Size)`n"
Write-Output "`tType: $($jsonObject.Disk.Type)`n"
Write-Output "`tName: $($jsonObject.Disk.Name)`n"

# Wait for user to press any key to exit
Write-Host "`nPress Enter to exit ..."
$null = Read-Host
