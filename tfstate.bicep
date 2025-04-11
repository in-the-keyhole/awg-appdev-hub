param defaultName string = 'awg-appdevhub'
param releaseName string = '1.0.0'
param defaultTags object = {}
param metadataLocation string = 'westus'
param resourceLocation string = 'eastus'

var tags = union(defaultTags, {
    defaultName: defaultName
    releaseName: releaseName
})

resource tfstate 'Microsoft.Storage/storageAccounts@2024-01-01' = {
    name: replace('${defaultName}tfstate', '-', '')
    tags: tags
    location: resourceLocation
    kind: 'BlobStorage'
    sku: { name: 'Standard_LRS' }

    properties: {
        accessTier: 'Hot'
        minimumTlsVersion: 'TLS1_2'
    }

    resource service 'blobServices' = {
        name: 'default'

        resource container 'containers' = {
            name: 'tfstate'
        }
    }
}
