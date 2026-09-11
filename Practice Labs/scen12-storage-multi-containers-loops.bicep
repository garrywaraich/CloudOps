param stglocation string = resourceGroup().location

var storageaccNames array = [
  'prod'
  'nonprod'
]

var blobcontainerNames array = [
  'images'
  'videos'
  'audios'
]

resource stgacc 'Microsoft.Storage/storageAccounts@2026-04-01' = [for (storage, i) in storageaccNames: {
  name: '${storage}${uniqueString(resourceGroup().id)}'
  location: stglocation
  sku:{
    name: 'Standard_LRS'
  }
  kind:'StorageV2'
  properties:{
    accessTier:'Hot'
  }
}]

resource blobservices 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = [for (bservice, j) in storageaccNames: {
  name: 'default'
  parent: stgacc[j]
}]

resource blobContainers1 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = [for blobs1 in blobcontainerNames:  {
  name: blobs1
  parent: blobservices[0]
  properties:{
    publicAccess:'None'
  }
}]

resource blobContainers2 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = [for blobs2 in blobcontainerNames:  {
  name: blobs2
  parent: blobservices[1]
  properties:{
    publicAccess:'None'
  }
}]

output stgaccinfo array = [for (item, i) in storageaccNames: {
  name: stgacc[i].name
  ID: stgacc[i].id
  endpoint: stgacc[i].properties.primaryEndpoints.blob
}]

output blobcontainerinfo1 array = [for item in range(0, length(blobcontainerNames)): {
  name: blobContainers1[item].name
  ID: blobContainers1[item].id
}]

output blobcontainerinfo2 array = [for item in range(0, length(blobcontainerNames)): {
  name: blobContainers2[item].name
  ID: blobContainers2[item].id
}]
