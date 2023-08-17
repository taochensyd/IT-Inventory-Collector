try {
    $delay = Read-Host -Prompt 'Enter the delay time (e.g. 10s, 5m, 1h)'
    if ($delay -match '^\d+[smh]$') {
        $unit = $delay.Substring($delay.Length - 1)
        $time = [int]$delay.Substring(0, $delay.Length - 1)

        switch ($unit) {
            's' { $seconds = $time }
            'm' { $seconds = $time * 60 }
            'h' { $seconds = $time * 3600 }
            default { Write-Output "Invalid time unit"; exit }
        }

        Write-Output "Shutting down in $seconds seconds. Press any key to cancel shutdown."
        for ($i = $seconds; $i -gt 0; $i--) {
            Write-Host "`rTime remaining: $i seconds" -NoNewline
            Start-Sleep -Seconds 1
            if ($host.UI.RawUI.KeyAvailable) {
                $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Write-Host "`nShutdown cancelled"
                exit
            }
        }
        Stop-Computer
    } else {
        Write-Output "Invalid delay time format"
    }
} catch {
    Write-Output "An error occurred: $($_.Exception.Message)"
}
