try {
    $filePath = Read-Host -Prompt "Enter the file path"
    $fileName = Read-Host -Prompt "Enter the file name"

    Get-ChildItem -Path $filePath -Filter "*$fileName*" -Recurse | ForEach-Object {
        Write-Output $_.FullName
    }
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}

Read-Host -Prompt "Press Enter to exit"
