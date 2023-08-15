$dir = "D:\Hyper-V\Exported VM"
Write-Output "Searching for files in directory: $dir"
$files = Get-ChildItem -Path $dir -Filter *.vhdx -Recurse
Write-Output "Found $($files.Count) files"
$fileNames = $files | ForEach-Object {$_.Name}
$fileCount = @{}
$fileNames | ForEach-Object {$fileCount[$_]++}
$filesToDelete = $fileCount.Keys | Where-Object {$fileCount[$_] -gt 5}
Write-Output "Found $($filesToDelete.Count) files with more than 5 occurrences"
foreach ($file in $filesToDelete) {
    Write-Output "Processing file: $file"
    $filesToKeep = $files | Where-Object {$_.Name -eq $file} | Sort-Object LastWriteTime -Descending | Select-Object -First 5
    Write-Output "Keeping the newest 5 files: $($filesToKeep.Name)"
    $filesToRemove = $files | Where-Object {$_.Name -eq $file} | Where-Object {$_.LastWriteTime -lt $filesToKeep[4].LastWriteTime}
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