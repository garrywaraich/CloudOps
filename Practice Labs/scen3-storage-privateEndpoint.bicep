param resourcenaming string = uniqueString(resourceGroup().id)

param locations string = resourceGroup().location

var vnetproperties = {
    vnet: {
      AddressSpace: '10.0.0.0/16'
    }
    sub1: {
      AddressSpace: '10.0.1.0/24'
    }
    sub2: {
      AddressSpace: '10.0.2.0/24'
    }
  }



resource virtualnetsymb 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: 'vnet-${resourcenaming}'
  location: locations
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetproperties.vnet.AddressSpace
      ]
    }
    subnets: [
      {
        name: 'sub1-${resourcenaming}'
        properties: {
          addressPrefix: vnetproperties.sub1.AddressSpace
        }
      }
    ]
  }
}

resource vnetsubnet2 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: 'sub2-${resourcenaming}'
  parent: virtualnetsymb
  properties: {
    addressPrefix: vnetproperties.sub2.AddressSpace
  }
}

resource StorageAccountsymb 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: 'st${uniqueString(resourceGroup().id)}'
  location: locations
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource PrivateEndpointsymb 'Microsoft.Network/privateEndpoints@2025-07-01' = {
  name: 'PrivateEndpoint-${resourcenaming}'
  location: locations
  properties: {
    subnet: {
      id: vnetsubnet2.id
    }
    privateLinkServiceConnections: [
      {
        name: 'PrivateStorageconnect'
        properties: {
          privateLinkServiceId: StorageAccountsymb.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

output StorageoutputID string = StorageAccountsymb.id
output PrivatendpOutputID string = PrivateEndpointsymb.id
