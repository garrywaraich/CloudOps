@description('The Storagearrays parameter is an array of storage account names to be created')
param Storagearrays array = [
    'storageaccount1'
    'storageaccount2'
]

@description('The locationarray parameter is an array of locations where the storage accounts will be created')
param locationarray array = [
    'eastus'
    'westus'
    'europe'
]

@description('Below resource creates storage accounts based on the Storagearrays parameter. For each item in the Storagearrays array, a storage account will be created with the specified name.')
resource StorageAccountsymb 'Microsoft.Storage/storageAccounts@2026-04-01' = [for item in Storagearrays: {
  name: item
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}]

@description('Below resource creates storage accounts based on the locationarray parameter. For each item in the locationarray array, a storage account will be created with the specified location and +1 added to index to generate name for storage account.')
resource StorageAccountsymb2 'Microsoft.Storage/storageAccounts@2026-04-01' = [for (setlocation, index) in locationarray: {
  name: 'storage-dev-${index + 1}'
  location: setlocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}]

@description('For simple creation of resources by defining range. It will create 3 storage accounts named st-0, st-1, st-2.')
resource StorageAccountsymb3 'Microsoft.Storage/storageAccounts@2026-04-01' = [for i in range(0, 3): {
  name: 'st-${i + 1}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}]
