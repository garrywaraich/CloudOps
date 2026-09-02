param location string = resourceGroup().location

param appserviceplanName string

param webappName string

param storageName string

var storageproperties = {
  name: 'stg${storageName}'
  skuname: 'Standard_LRS'
  kind: 'StorageV2'
  accessTier: 'Hot'
}

resource appserviceplan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appserviceplanName
  location: location
  sku: {
    tier: 'F1'
    name: 'F1'
  }
}

resource webapp 'Microsoft.Web/sites@2025-03-01' = {
  name: webappName
  location: location
  properties: {
    enabled: true
    ipMode: 'IPv4'
    serverFarmId: appserviceplan.id
    }
}


resource storageacc 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: storageproperties.name
  location: location
  sku: {
    name: storageproperties.skuname
  }
  kind: storageproperties.kind
  properties: {
    accessTier: storageproperties.accessTier
  }
}

output webappURL string = 'https://${webapp.properties.defaultHostName}'
output stgname string = storageacc.name
