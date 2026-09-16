var vnetproperties = {
  name: 'prod-vnet-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  addressPrefix: '10.0.0.0/16'

  subnet: {
    name: 'sub1'
      addressPrefix: '10.0.1.0/24'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name: vnetproperties.name
  location: vnetproperties.location
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetproperties.addressPrefix
      ]
    }
  }
}

resource vsubnet 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  name: vnetproperties.subnet.name
  parent: vnet
  properties:{
    addressPrefix: vnetproperties.subnet.addressPrefix
  }
}


resource stgacc 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'st${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties:{
   accessTier: 'Hot' 
   publicNetworkAccess: 'Disabled'
  }
}

resource blobservice 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  name: 'default'
  parent: stgacc
}

resource blobcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
  name: 'images'
  parent: blobservice
  properties:{
    publicAccess: 'None'
  }
}

resource stgendpoint 'Microsoft.Network/privateEndpoints@2025-09-01' = {
  name: 'blob-privateendpoint'
  location: resourceGroup().location
  properties:{
    subnet: {
      id: vsubnet.id
    }
    privateLinkServiceConnections:[
      {
        name: 'privatestgacc'
        properties:{
          privateLinkServiceId: stgacc.id
          groupIds:[
            'blob'
          ]
        }
      }
    ]
  } 
}

output storageaccountID string = stgacc.id

output containerID string = blobcontainer.id

output privateEndpointID string = stgendpoint.id
