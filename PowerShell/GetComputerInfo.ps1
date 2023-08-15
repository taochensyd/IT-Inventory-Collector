$computerList = 160..190 | ForEach-Object { "192.168.0.$_" }

foreach ($computer in $computerList) {
    $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer
    $bios = Get-WmiObject -Class Win32_BIOS -ComputerName $computer
    $processor = Get-WmiObject -Class Win32_Processor -ComputerName $computer
    $disk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computer | Where-Object {$_.DriveType -eq 3}

    [PSCustomObject]@{
        ComputerName = $computer
        OSVersion = $os.Caption
        BIOSVersion = $bios.SMBIOSBIOSVersion
        Processor = $processor.Name
        DiskSizeGB = [math]::Round($disk.Size / 1GB, 2)
        FreeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    }
}
