var blobcontainerNames1 = [for i in range(1,3): 'Images${i}-${uniqueString(resourceGroup().id)}']

var blobcontainerNames2 = [for i in range(1,3): 'Videos${i}-${uniqueString(resourceGroup().id)}']

resource stgacc1 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'st1-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku:{
    name: 'Standard_LRS'
  }
  kind:'StorageV2'
  properties:{
    accessTier:'Hot'
  }
}

resource blobservice1 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  name: 'default'
  parent: stgacc1
}

resource blobContainers1 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = [for blobs1 in blobcontainerNames1: {
  name: blobs1
  parent: blobservice1
  properties:{
    publicAccess:'None'
  }
}]

resource stgacc2 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'st2-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku:{
    name: 'Standard_LRS'
  }
  kind:'StorageV2'
  properties:{
    accessTier:'Hot'
  }
}

resource blobservice2 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  name: 'default'
  parent: stgacc2
}

resource blobContainers2 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = [for blobs2 in blobcontainerNames2: {
  name: blobs2
  parent: blobservice2
  properties:{
    publicAccess:'None'
  }
}]
