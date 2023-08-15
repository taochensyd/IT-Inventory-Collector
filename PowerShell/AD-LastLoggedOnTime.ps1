Import-Module ActiveDirectory

function Get-ADUserLastLogon {
    $dcs = Get-ADDomainController -Filter {Name -like "*"}
    $users = Get-ADUser -Filter *
    $results = @()
    foreach ($user in $users) {
        $time = 0
        foreach ($dc in $dcs) {
            $hostname = $dc.HostName
            $currentUser = Get-ADUser $user.SamAccountName | Get-ADObject -Server $hostname -Properties lastLogon
            if ($currentUser.LastLogon -gt $time) {
                $time = $currentUser.LastLogon
            }
        }
        $dt = [DateTime]::FromFileTime($time)
        Write-Host $user.SamAccountName "last logged on at:" $dt
        $results += New-Object PSObject -Property @{
            AccountName = $user.SamAccountName
            LastLoggedTime = $dt
        }
    }
    # Replace "C:\Path\To\OutputFile.csv" with a valid path on your system
    $results | Export-Csv -Path "C:\outputFile.csv" -NoTypeInformation
}

Get-ADUserLastLogon
