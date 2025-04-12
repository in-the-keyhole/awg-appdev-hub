#Requires -Version 7.4
#Requires -Modules Az.Accounts
#Requires -Modules powershell-yaml

[CmdletBinding(SupportsShouldProcess=$true)]

param(
    [ValidateSet('all', 'bicep', 'tf')]
    [string]$Stage = 'all',

    [string]$TfStateResourceGroupName = "tfstate",
    [string]$TfStateStorageAccountName = "awgappdevhubtfstate",

    [string]$DefaultName = 'awg-hub',
    [string]$ReleaseName = '1.0.0',
    [hashtable]$DefaultTags = @{},
    
    [Parameter(Mandatory)][string]$MetadataLocation,
    [Parameter(Mandatory)][string]$ResourceLocation,

    [Parameter(Mandatory)][string]$DnsZoneName,
    [Parameter(Mandatory)][string]$InternalDnsZoneName,

    [Parameter(Mandatory)][string]$VnetAddressPrefix,
    [Parameter(Mandatory)][string]$PrivateVnetSubnetAddressPrefix,
    [Parameter(Mandatory)][string]$DefaultVnetSubnetAddressPrefix,
    [Parameter(Mandatory)][string]$DnsInboundVnetSubnetAddressPrefix,
    [Parameter(Mandatory)][string]$DnsOutboundVnetSubnetAddressPrefix,
    [Parameter(Mandatory)][string]$BastionVnetSubnetAddressPrefix
)

$ErrorActionPreference = "Stop"

if ((Get-Command 'az').CommandType -ne 'Application') {
    throw 'Missing az command.'
}

$SubscriptionId = $(az account show --query id --output tsv)
if (!$SubscriptionId) {
        throw 'Missing current Azure subscription.'
}

if ($Stage -eq 'all' -or $Stage -eq 'bicep') {
    # create tfstate resource group
    az group create -l $MetadataLocation -n rg-$DefaultName-tfstate `
    ; if ($LASTEXITCODE -ne 0) { throw $LASTEXITCODE }

    # use bicep for initial tfstate deployment
    az deployment group create `
        --resource-group rg-$DefaultName-tfstate `
        --template-file tfstate.bicep `
        --parameters defaultName="$DefaultName" `
        --parameters releaseName="$ReleaseName" `
        --parameters metadataLocation="$MetadataLocation" `
        --parameters resourceLocation="$ResourceLocation" `
        ; if ($LASTEXITCODE -ne 0) { throw $LASTEXITCODE }
}

if ($Stage -eq 'all' -or $Stage -eq 'tf') {
    if ((Get-Command 'terraform').CommandType -ne 'Application') {
        throw 'Missing terraform command.'
    }

    New-Item -ItemType Directory .tmp -Force | Out-Null

    @{
        subscription_id = $SubscriptionId
        default_name = $DefaultName
        release_name = $ReleaseName
        default_tags = $DefaultTags
        metadata_location = $MetadataLocation
        resource_location = $ResourceLocation
        dns_zone_name = $DnsZoneName
        int_dns_zone_name = $InternalDnsZoneName
        vnet_address_prefixes = @( $VnetAddressPrefix )
        default_vnet_subnet_address_prefixes = @( $DefaultVnetSubnetAddressPrefix )
        private_vnet_subnet_address_prefixes = @( $PrivateVnetSubnetAddressPrefix )
        dns_inbound_vnet_subnet_address_prefixes = @( $DnsInboundVnetSubnetAddressPrefix )
        dns_outbound_vnet_subnet_address_prefixes = @( $DnsOutboundVnetSubnetAddressPrefix )
        bastion_vnet_subnet_address_prefixes = @( $BastionVnetSubnetAddressPrefix )
    } | ConvertTo-Json | Out-File .tmp/$DefaultName.tfvars.json

    Push-Location .\terraform

    try {
        # configure terraform against target environment
        terraform init -reconfigure `
            -backend-config "subscription_id=$SubscriptionId" `
            -backend-config "resource_group_name=$TfStateResourceGroupName" `
            -backend-config "storage_account_name=$TfStateStorageAccountName" `
            -backend-config "container_name=tfstate" `
            -backend-config "key=${DefaultName}.tfstate"; if ($LASTEXITCODE -ne 0) { throw $LASTEXITCODE }

        # apply terraform against target environment
        terraform apply `
            -var-file="../.tmp/$DefaultName.tfvars.json" `
            -auto-approve; if ($LASTEXITCODE -ne 0) { throw $LASTEXITCODE }

    } finally {
        Pop-Location
    }
}
