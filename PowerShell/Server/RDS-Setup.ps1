# Join computer to domain
$domain = "homart.local"
$credential = Get-Credential

$computerName = Read-Host -Prompt "Enter the computer name"

Add-Computer -DomainName $domain -Credential $credential -NewName $computerName -Force

# Create local user accounts and add them to the Administrators group
$users = @("admin", "admin2", "admin3")
$group = "Administrators"

foreach ($user in $users) {
    $password = Read-Host -AsSecureString -Prompt "Enter password for $user"
    New-LocalUser -Name $user -Password $password
    Add-LocalGroupMember -Group $group -Member $user
}
