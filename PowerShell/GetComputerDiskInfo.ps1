$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
$networkLoginProfile = Get-WmiObject -Class Win32_NetworkLoginProfile | Where-Object {$_.Name -match [Environment]::UserName}
$ipV4Address = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.0.*"}).IPAddress
$physicalDisks = Get-PhysicalDisk | Select-Object DeviceID, MediaType, FriendlyName, Size, HealthStatus

$props = @{
    'PC Hostname' = $computerSystem.Name;
    'Joined Domain' = $computerSystem.PartOfDomain;
    'Logged-in Username' = [Environment]::UserName;
    'IP Address' = $ipV4Address;
    'Physical Disks' = $physicalDisks;
}

$json = $props | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "http://192.168.0.165:6000/api/pc/info" -Body $json -ContentType "application/json"
