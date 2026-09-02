param locations array = [
  'eastus'
  'westus'
  'centralus'
]

var storageaccproperties = {
  skuname: 'Standard_LRS'
  kind: 'StorageV2'
  accessTier: 'Hot'
}

resource storageacc 'Microsoft.Storage/storageAccounts@2026-04-01' = [for location in locations: {
  name: 'stg${uniqueString(resourceGroup().id, location)}'
  location: location
  sku: {
    name: storageaccproperties.skuname
  }
  kind: storageaccproperties.kind
  properties: {
    accessTier: storageaccproperties.accessTier
  }
}]

output storagenames array = [for item in range(0, length(locations)): {
  name: storageacc[item].name
  location: storageacc[item].location
  id: storageacc[item].id
}]
