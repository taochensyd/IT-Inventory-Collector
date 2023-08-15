$shell = New-Object -ComObject Shell.Application
$folder = $shell.NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}')
$items = $folder.Items()

foreach ($item in $items) {
    $verb = $item.Verbs() | where { $_.Name.replace('&', '') -eq 'Unpin from Start' }
    if ($verb) {
        $verb.DoIt()
    }
}

function Pin-App {
    param(
        [string]$appname,
        [switch]$unpin
    )
    try{
        if ($unpin.IsPresent){
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Von "Start" lösen|Unpin from Start'} | %{$_.DoIt()}
            return "App '$appname' unpinned from Start"
        }else{
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'An "Start" anheften|Pin to Start'} | %{$_.DoIt()}
            return "App '$appname' pinned to Start"
        }
    }catch{
        Write-Error "Error Pinning/Unpinning App! (App Name correct?)"
    }
}

$appNames = @("Word", "Excel", "Outlook", "Google Chrome", "SAP Business One Client (64-bit)", "File Explorer", "TIM", "WeChat", "Control Panel")
foreach ($appName in $appNames) {
    Pin-App $appName -pin
}
Pin-App "TIM" -unpin
Pin-App "WeChat" -unpin