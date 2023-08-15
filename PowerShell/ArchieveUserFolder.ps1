function Archive-StuffFolder {
    param(
        [string]$accountName,
        [string]$userFullName
    )
    $date = Get-Date -Format "yyyyMMdd"
    $folderPath = "D:\stuff\$accountName"
    if (Test-Path $folderPath) {
        Write-Host "Renaming folder..."
        $newName = "$accountName $date $userFullName"
        Rename-Item $folderPath $newName
        Write-Host "Folder renamed from '$folderPath' to 'D:\stuff\$newName'"
        Write-Host "Moving folder to _Archive..."
        Move-Item "D:\stuff\$newName" "D:\_Archive\$newName"
        Write-Host "Folder moved to 'D:\_Archive\$newName'"
    } else {
        Write-Host "Folder not found."
    }
}

function Archive-FDriveFolder {
    param(
        [string]$accountName
    )
    $date = Get-Date -Format "yyyyMMdd"
    $folders = Get-ChildItem -Path "F:\" -Directory | Where-Object { $_.Name.StartsWith($accountName) }
    foreach ($folder in $folders) {
        Write-Host "Archiving folder '$($folder.FullName)'..."
        Rename-Item $folder.FullName "$($folder.Name)~Archive $date"
        Write-Host "Folder archived as '$($folder.Name)~Archive $date'"
    }
}

$accountName = Read-Host -Prompt 'Enter the account name'
$userFullName = Read-Host -Prompt 'Enter the user full name'

Archive-StuffFolder -accountName $accountName -userFullName $userFullName
Archive-FDriveFolder -accountName $accountName

Write-Host "Press any key to exit..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")