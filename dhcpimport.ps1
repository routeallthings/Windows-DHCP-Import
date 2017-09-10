##########################################
#
#	---AUTHOR---
#	Name: Matt Cross
#	Email: routeallthings@gmail.com
#
#	---PREREQ---
#	None
#
#	---VERSION---
#	VERSION 1.0
#
#	---NAME---
#	DHCP IMPORT SCRIPT
#
##########################################
#	Global Variables
##########################################
if (!(Get-Command 'Import-DHCPServer' -errorAction SilentlyContinue))
{
	write-host 'Failed to find DHCP Server cmdlets. Please make sure you have the server manager tools installed'
	exit
}
$importcsv = Read-Host -Prompt 'Enter the path of the CSV file for import (e.g. C:\template.csv)'
if ($importcsv -eq '') { $importcsv = 'template.csv' }
$dhcphost = Read-Host -Prompt 'Enter the FQDN of the DHCP server'
if ($dhcphost -eq '') { 
Write-Host 'No name entered. Assuming localhost.'
$dhcphost = 'localhost'
}
$dhcpgatewayq = Read-Host -Prompt 'What IP do you want to set as the default gateway for each subnet (e.g. 10.10.10.1 = 1)?'
##########################################
#Start of script
##########################################
Write-host '----------------------------------------------------------------------------------'
Write-host 'Starting to import'$importcsv' into '$dhcphost'.'
Write-host '----------------------------------------------------------------------------------'
import-csv $importcsv | Add-DhcpServerv4Scope -cn $dhcphost
Write-host 'Importing...'
$namevalues = import-csv $importcsv | % {$_.Name}
Foreach ($name in $namevalues){
	$dhcpname = Get-DhcpServerv4Scope -cn $dhcphost | ? name -match $name |  % {$_.Name}
	$dhcpsubnet = Get-DhcpServerv4Scope -cn $dhcphost | ? name -match $name |  % {$_.StartRange}
	$dhcpscopeid = Get-DhcpServerv4Scope -cn $dhcphost | ? name -match $name |  % {$_.ScopeId}
	$dhcpsubnet = $dhcpsubnet.IPAddressToString | Out-String
	$dhcpsubnet = $dhcpsubnet.Split('.')
	$dhcpsubnet[-1] = $dhcpgatewayq
	$dhcpgateway = ''
	$dhcpgateway = $dhcpsubnet -join'.'
	Set-DhcpServerv4OptionValue -ScopeId $dhcpscopeid -ComputerName $dhcphost -Router $dhcpgateway
	if ($name -eq $dhcpname) {Write-host 'Successfully imported the DHCP scope:'$name' and set the gateway to '$dhcpgateway}}
Write-host '----------------------------------------------------------------------------------'