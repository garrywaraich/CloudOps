@allowed([
  'dev'
  'test'
  'prod'
])

param environmentType string

var stgproperties =  {
    name: 'stg-${environmentType}'
    location: (environmentType == 'prod' || environmentType == 'test' ? 'eastus' : 'westus')
    sku: (environmentType == 'prod' || environmentType == 'test' ? 'Standard_ZRS' : 'Standard_LRS')
    kind: 'StorageV2'
    accessTier: (environmentType == 'prod' || environmentType == 'test' ? 'Hot' : 'Cool')
  }


resource stgacc 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: stgproperties.name
  location: stgproperties.location
  sku: {
    name: stgproperties.sku
  }
  kind: stgproperties.kind
  properties: {
    accessTier: stgproperties.accessTier
  }
}
