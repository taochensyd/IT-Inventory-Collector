$internalGateway = "192.168.0.254"
$externalAddress = "8.8.8.8"
$dnsServers = @("192.168.0.21", "192.168.0.22")

Write-Output "Network adapters:"
Get-NetAdapter | Format-Table -Property Name, InterfaceDescription, Status, LinkSpeed

Write-Output "`nIP configuration:"
Get-NetIPConfiguration | Format-List -Property InterfaceAlias, IPv4Address, IPv6Address, DNSServer

Write-Output "`nTesting internal connectivity to ${internalGateway}:"
Test-NetConnection -ComputerName $internalGateway | Format-List -Property ComputerName, PingSucceeded, PingReplyDetails

foreach ($dnsServer in $dnsServers) {
    Write-Output "`nTesting internal connectivity to DNS server ${dnsServer}:"
    Test-NetConnection -ComputerName $dnsServer | Format-List -Property ComputerName, PingSucceeded, PingReplyDetails
}

Write-Output "`nTesting external connectivity to ${externalAddress}:"
Test-NetConnection -ComputerName $externalAddress | Format-List -Property ComputerName, PingSucceeded, PingReplyDetails

Write-Output "`nTracing route to ${externalAddress}:"
Test-NetConnection -ComputerName $externalAddress -TraceRoute | Select-Object -ExpandProperty TraceRoute

Write-Output "`nTesting DNS resolution for ${externalAddress}:"
Resolve-DnsName -Name $externalAddress | Format-List -Property Name, IPAddress

Write-Output "`nIP routing table:"
Get-NetRoute | Format-Table -Property DestinationPrefix, NextHop, RouteMetric, InterfaceAlias

Write-Output "`nWindows Firewall status:"
$firewallStatus = (Get-NetFirewallProfile).Enabled
if ($firewallStatus -eq $true) {
    Write-Output "Windows Firewall is enabled"
} else {
    Write-Output "Windows Firewall is disabled"
}

Write-Output "`nRemote Desktop firewall rule status:"
$firewallRule = Get-NetFirewallRule | Where-Object {$_.DisplayName -eq "Remote Desktop" -and $_.Direction -eq "Inbound"}
if ($null -ne $firewallRule) {
    Write-Output "Remote Desktop firewall rule: $($firewallRule.Enabled)"
} else {
    Write-Output "Remote Desktop firewall rule not found"
}


# Prevent the window from closing
Read-Host -Prompt "Press Enter to exit"