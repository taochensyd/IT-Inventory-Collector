# Set the computer name and file extension
$computerName = $env:COMPUTERNAME
$extension = ".ost"
$outputFile = "C:\Admin\Close-OST-Script.txt"

# Get a list of all open files with the specified extension
Write-Output "Retrieving open files with the '$extension' extension..." | Out-File -Append $outputFile
$openFiles = Get-SmbOpenFile | Where-Object { $_.Path -like "*$extension" }

# Print out all open files
Write-Output "Open files:" | Out-File -Append $outputFile
foreach ($file in $openFiles) {
    Write-Output "  - $($file.Path)" | Out-File -Append $outputFile
}

# Close each open file
foreach ($file in $openFiles) {
    Write-Output "Closing file: $($file.Path)" | Out-File -Append $outputFile
    Close-SmbOpenFile -FileId $file.FileId -Force
}

Write-Output "All shared open files with the '$extension' extension have been closed." | Out-File -Append $outputFile
