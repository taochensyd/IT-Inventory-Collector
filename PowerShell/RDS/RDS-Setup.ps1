# Ask User pc name and set the name
$pcName = Read-Host -Prompt "Enter the PC name"
Rename-Computer -NewName $pcName

# Join Domain, ask user to enter domain url, admin username and password, and no restart
$domain = Read-Host -Prompt "Enter the domain URL"
$username = Read-Host -Prompt "Enter the admin username"
$password = Read-Host -Prompt "Enter the admin password" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($username, $password)
Add-Computer -DomainName $domain -Credential $credential -Restart:$false

# Setup local Account admin, admin2, admin3 and ask user to enter password with each account
$adminAccounts = @("admin", "admin2", "admin3")
foreach ($account in $adminAccounts) {
    $password = Read-Host -Prompt "Enter the password for $account" -AsSecureString
    New-LocalUser -Name $account -Password $password
    Add-LocalGroupMember -Group "Administrators" -Member $account
}

# Turn off firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Set static IP address(Ask user to enter the ip) subnet mask is 255.255.255.0 and default gateway is 192.168.0.254
$ipAddress = Read-Host -Prompt "Enter the IP address"
$subnetMask = "255.255.255.0"
$defaultGateway = "192.168.0.254"
New-NetIPAddress -IPAddress $ipAddress -PrefixLength 24 -DefaultGateway $defaultGateway

# Set language for non-Unicode programs to "Non-unicode(chinese-china)", this is in control panel, region, administrative, change system locale
Set-WinSystemLocale zh-CN

# Import printer, just output and remind user to import printer manually using printmanagement.msc
Write-Output "Please import printer manually using printmanagement.msc"
