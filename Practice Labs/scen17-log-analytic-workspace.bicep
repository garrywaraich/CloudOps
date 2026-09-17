param enableworkspace bool

param location string = resourceGroup().location

resource stgacc 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'stg${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource logworkspace 'Microsoft.OperationalInsights/workspaces@2026-03-01' = if (enableworkspace) {
  name: 'workspace${uniqueString(resourceGroup().id)}'
  location: location
  properties:{
    sku:{
      name: 'PerGB2018'
    }
  }
}

output storageID string = stgacc.id

output workspaceID string = enableworkspace ? logworkspace.id : 'Monitoring Disabled'
