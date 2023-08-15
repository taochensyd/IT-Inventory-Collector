$path = Read-Host -Prompt 'Enter the path of the file or folder to delete'
if (Test-Path $path) {
    $confirmation = Read-Host -Prompt "Are you sure you want to delete $path? (y/n)"
    if ($confirmation -eq 'y') {
        Remove-Item $path -Recurse -Force
        Write-Host "$path has been deleted"
    } else {
        Write-Host "Deletion cancelled"
    }
} else {
    Write-Host "The path $path does not exist"
}
Read-Host -Prompt "Press Enter to exit"