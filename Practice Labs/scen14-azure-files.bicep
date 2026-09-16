param stgproperties object = {
  name: 'stg${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  skuname: 'Standard_LRS' 
  kind: 'StorageV2'
}

var shareNames = [
  'share1-${stgproperties.name}'
  'share2-${stgproperties.name}'
]

var shareproperties = {
  accessTier: 'Hot'
  quota: 100
  protocols: 'SMB'
}

resource stgacc 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: stgproperties.name
  location: stgproperties.location
  sku: {
    name: stgproperties.skuname
  }
  kind: stgproperties.kind
}

resource fileservice 'Microsoft.Storage/storageAccounts/fileServices@2026-04-01' = {
  name: 'default'
  parent: stgacc
}

resource fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2026-04-01' = [for item in shareNames: {
  name: item
  parent: fileservice
  properties:{
    accessTier: shareproperties.accessTier
    enabledProtocols: shareproperties.protocols
    shareQuota: shareproperties.quota
  }
}]

output stgaccinfo object = {
  name: stgacc.name
  stgID: stgacc.id
  stgURL: stgacc.properties.primaryEndpoints.file
}

output fileshare array = [
  for i in range(0, length(shareNames)): {
    name: fileshare[i]
    ID: fileshare[i].id
    protocol: fileshare[i].properties.enabledProtocols
  }
]
