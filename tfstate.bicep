param storageAccountName string
param resourceLocation string

resource tfstate 'Microsoft.Storage/storageAccounts@2024-01-01' = {
    name: storageAccountName
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
