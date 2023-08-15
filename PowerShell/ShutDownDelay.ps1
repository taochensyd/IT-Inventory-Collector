$delay = Read-Host -Prompt 'Enter the delay time (e.g. 10s, 5m, 1h)'
$unit = $delay.Substring($delay.Length - 1)
$time = [int]$delay.Substring(0, $delay.Length - 1)

switch ($unit) {
    's' { $seconds = $time }
    'm' { $seconds = $time * 60 }
    'h' { $seconds = $time * 3600 }
    default { Write-Output "Invalid time unit"; exit }
}

Write-Output "Shutting down in $seconds seconds"
Start-Sleep -Seconds $seconds
Stop-Computer
