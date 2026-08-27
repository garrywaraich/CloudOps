@description('This variable is used to define the environment type for the storage account')
@allowed([
  'prod'
  'nonprod'
])

param environmentType string

@description('This variable generate the storage account name using uniqueString function from resource group id')
param storageAccountName string = 'St-${environmentType}${uniqueString(resourceGroup().id)}'

@description('Define location of resource to deploy, else it will take the default location of resource group')
param location string = resourceGroup().location

@description('This variable is used to define the SKU name of the storage account based on the environment type')
var StorageSKUname = (environmentType == 'prod' ? 'Standard_GRS' : 'Standard_LRS')

@description('This variable is used to define the access tier of the storage account based on the environment type')
var StorageAccessTier = (environmentType == 'prod' ? 'Hot' : 'Cool')

resource StorageAccountsymbolic 'Microsoft.Storage/storageAccounts@2026-04-01' = if (environmentType == 'Prod') {
  name: storageAccountName
  location: location
  sku: {
    name: StorageSKUname
  }
  kind: 'StorageV2'
  properties: {
    accessTier: StorageAccessTier
    supportsHttpsTrafficOnly: true
  }
}
resource BlobServiceSymb 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = if (environmentType == 'Prod') {
  name: 'default'
  parent: StorageAccountsymbolic
}

resource BlobContainersymb 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = if (environmentType == 'prod') {
  name: 'images'
  parent: BlobServiceSymb
}
