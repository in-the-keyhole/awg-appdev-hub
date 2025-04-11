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
    -DefaultName "awg-appdevhub" `
    -ReleaseName "1.0.0" `
    -DefaultTags @{} `
    -MetadataLocation "westus" `
    -ResourceLocation "eastus" `
    -DnsZoneName "az.awginc.com" `
    -InternalDnsZoneName "az.int.awginc.com" `
    -VnetAddressPrefix "10.223.0.0/16" `
    -DefaultVnetSubnetAddressPrefix "10.223.0.0/24" `
    -PrivateVnetSubnetAddressPrefix "10.223.1.0/24" `
    -BastionVnetSubnetAddressPrefix "10.223.2.0/24"
