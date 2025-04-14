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
    -TfStateResourceGroupName "rg-appdev-tfstate" `
    -TfStateStorageAccountName "appdevtfstate" `
    -DefaultName "awg-hub" `
    -ReleaseName "1.0.0" `
    -DefaultTags @{} `
    -MetadataLocation "northcentralus" `
    -ResourceLocation "southcentralus" `
    -DnsZoneName "az.awginc.com" `
    -InternalDnsZoneName "az.int.awginc.com" `
    -DnsResolverAddresses @( "10.223.254.4", "10.223.254.5" ) `
    -DnsResolverRules @{
        "labs.appdev.az.int.awginc.com" = @(
            "10.224.254.4",
            "10.224.254.5"
        )
        "awg-appdev-labs.privatelink.southcentralus.azmk8s.io" = @(
            "10.224.254.4",
            "10.224.254.5"
        )
    } `
    -VnetDnsServers @( "10.223.254.4", "10.223.254.5" ) `
    -VnetAddressPrefix "10.223.0.0/16" `
    -DefaultVnetSubnetAddressPrefix "10.223.0.0/24" `
    -PrivateVnetSubnetAddressPrefix "10.223.1.0/24" `
    -DnsVnetSubnetAddressPrefix "10.223.254.0/29" `
    -BastionVnetSubnetAddressPrefix "10.223.255.0/26" `
    -VnetPeers @{
        "awg-appdev-labs" = "/subscriptions/6190d2d3-f65d-4f7a-939e-ad9829c27fd5/resourceGroups/rg-awg-appdev-labs/providers/Microsoft.Network/virtualNetworks/awg-appdev-labs"
    } `
    -DnsPeers @{
        "labs.appdev" = @(
            "ns1-01.azure-dns.com.",
            "ns1-01.azure-dns.net.",
            "ns1-01.azure-dns.org.",
            "ns1-01.azure-dns.info."
        )
    }
