$source = Read-Host -Prompt 'Enter the source path'
$destination = Read-Host -Prompt 'Enter the destination path'

if (!(Test-Path $source)) {
    Write-Output "Source path does not exist"
    exit
}

if (!(Test-Path $destination)) {
    Write-Output "Destination path does not exist"
    exit
}

Write-Output "Copying item from $source to $destination"
Copy-Item -Path $source -Destination $destination -Recurse -Verbose
Write-Output "Copy completed"

while ($true) {
    Start-Sleep -Seconds 1
}
