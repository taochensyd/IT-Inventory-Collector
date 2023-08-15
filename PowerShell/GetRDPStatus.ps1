$internalGateway = "192.168.0.254"
$externalAddress = "8.8.8.8"
$dnsServers = @("192.168.0.21", "192.168.0.22")

Write-Output "Network adapters:"
Get-NetAdapter | Format-Table -Property Name, InterfaceDescription, Status, LinkSpeed

Write-Output "`nIP configuration:"
Get-NetIPConfiguration | Format-List -Property InterfaceAlias, IPv4Address, IPv6Address, DNSServer

Write-Output "`nTesting internal connectivity to $internalGateway:"
Test-NetConnection -ComputerName $internalGateway | Format-List -Property ComputerName, PingSucceeded, PingReplyDetails

foreach ($dnsServer in $dnsServers) {
    Write-Output "`nTesting internal connectivity to DNS server $dnsServer:"
    Test-NetConnection -ComputerName $dnsServer | Format-List -Property ComputerName, PingSucceeded, PingReplyDetails
}

Write-Output "`nTesting external connectivity to $externalAddress:"
Test-NetConnection -ComputerName $externalAddress | Format-List -Property ComputerName, PingSucceeded, PingReplyDetails

Write-Output "`nTracing route to $externalAddress:"
Test-NetConnection -ComputerName $externalAddress -TraceRoute | Select-Object -ExpandProperty TraceRoute

# Prevent the window from closing
Read-Host -Prompt "Press Enter to exit"
