function Disconnect-UserSession {
    param(
        [string]$Server,
        [string]$SessionName
    )

    logoff $SessionName /server:$Server
}

$servers = @("rds01", "rds02", "rds03", "rds04", "rds05", "rds06", "rds07", "rds08")

foreach ($server in $servers) {
    Write-Output ""
    Write-Output $server
    qwinsta /server:$server
}

$disconnectSession = Read-Host -Prompt "Do you want to disconnect a user session? (yes/no)"

if ($disconnectSession -eq "yes") {
    $serverToDisconnect = Read-Host -Prompt "Enter the server name"
    $sessionToDisconnect = Read-Host -Prompt "Enter the session name"

    Disconnect-UserSession -Server $serverToDisconnect -SessionName $sessionToDisconnect
}

Read-Host -Prompt "Press Enter to exit"