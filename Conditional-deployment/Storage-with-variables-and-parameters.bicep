@description('This variable generate the storage account name using uniqueString function from resource group id')
var storageAccountName = 'St${uniqueString(resourceGroup().id)}'

@description('Define location of resource to deploy, else it will take the default location of resource group')
param location string = resourceGroup().location

resource StorageAccountsymbolic 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
  }
}
