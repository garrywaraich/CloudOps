@description('Define the environment type for the deployment. Allowed values are "prod" and "nonprod".')
@allowed ([
  'prod'
  'nonprod'
])

param environmentType string = 'prod'

param location object = {
  location1: 'eastus'
  location2: 'eastus2'
  location3: 'centralus'
  location4: 'westus'
}

@description('Define StorageAccountName with uniqueString function to generate unique name for Storage account')
var StorageAccountName = 'St-${environmentType}-FileShare'

@description('Define StorageSKUname based on environment type. If environment type is "prod", use "Standard_LRS"; otherwise, use "Standard_GRS".')
var StorageSKUname = (environmentType == 'prod' ? 'Standard_LRS' : 'Standard_GRS')

@description('Deploy Storage Account and File Share based on the environment type. If environment type is "prod" or "nonprod", deploy the resources; otherwise, skip deployment.')
resource StorageAccountFileshsare 'Microsoft.Storage/storageAccounts@2026-04-01' = if (environmentType == 'prod' || environmentType == 'nonprod') {
  name: StorageAccountName
  location: location.location1
  sku: {
    name: StorageSKUname
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource FileServicesymb 'Microsoft.Storage/storageAccounts/fileServices@2026-04-01' = if (environmentType == 'prod' || environmentType == 'nonprod') {
  name: 'default'
  parent: StorageAccountFileshsare
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource FileSharesymb 'Microsoft.Storage/storageAccounts/fileServices/shares@2026-04-01' = if (environmentType == 'prod' || environmentType == 'nonprod') {
  name: 'myfileshare'
  parent: FileServicesymb
  properties: {
    shareQuota: 100
    accessTier: 'Hot'
    enabledProtocols: 'NFS'
  }
}
