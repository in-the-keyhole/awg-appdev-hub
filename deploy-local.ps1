#Requires -Version 7.4
#Requires -Modules Az.Accounts
#Requires -Modules powershell-yaml

[CmdletBinding(SupportsShouldProcess=$true)]

param(
    [ValidateSet('all', 'bicep', 'tf')]
    [string]$Stage = 'all'
)

.\deploy.ps1 `
    -Stage $Stage `
    -DefaultName "awg-hub" `
    -ReleaseName "1.0.0" `
    -DefaultTags @{} `
    -MetadataLocation "northcentralus" `
    -ResourceLocation "southcentralus" `
    -DnsZoneName "az.awginc.com" `
    -InternalDnsZoneName "az.int.awginc.com" `
    -VnetAddressPrefix "10.223.0.0/16" `
    -DefaultVnetSubnetAddressPrefix "10.223.0.0/24" `
    -PrivateVnetSubnetAddressPrefix "10.223.1.0/24" `
    -DnsInboundVnetSubnetAddressPrefix "10.223.254.0/28" `
    -DnsOutboundVnetSubnetAddressPrefix "10.223.254.16/28" `
    -BastionVnetSubnetAddressPrefix "10.223.255.0/26"
