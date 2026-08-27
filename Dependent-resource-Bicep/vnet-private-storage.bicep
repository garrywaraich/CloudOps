@allowed([
  'prod'
  'nonprod'
])

param environmentType string

//var deploymentvalue = environmentType == 'prod' || environmentType == 'nonprod' ? true : false

var location = {
    primary: 'eastus'
    secondary: 'westus'
    tertiary: 'centralus'
}

var VNETname = 'myVnet${location.primary}-${environmentType}'

var Subnetname = {
    subnet1: 'mySubnet1-${environmentType}'
    subnet2: 'mySubnet2-${environmentType}'
    subnet3: 'mySubnet3-${environmentType}'
}

var StorageAccountName = 'mystorage${environmentType}${uniqueString(resourceGroup().id)}'

resource VirtualNetworksymb 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: VNETname
  location: location.primary
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: Subnetname.subnet1
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

output virtualNetworkId string = VirtualNetworksymb.id

resource VirtualNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
    parent: VirtualNetworksymb
    name: Subnetname.subnet2
    properties: {
        addressPrefix: '10.0.2.0/24'
    }
}

resource StorageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: StorageAccountName
  location: location.secondary
  tags: {
    environment: environmentType
    ManagedBy: 'Bicep'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
    properties: {
        networkAcls: {
            defaultAction: 'Deny'
            bypass: 'AzureServices'
            virtualNetworkRules: [
                {
                    id: VirtualNetworkSubnet.id
                    action: 'Allow'
                }
            ]
        }
    }
}

output storageAccountname string = StorageAccount.name
output StorageAccountId string = StorageAccount.id

resource StorageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  parent: StorageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
  }
}

resource StorageAccountBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
  parent: StorageAccountBlobService
  name: 'mycontainer'
  properties: {
    publicAccess: 'None'
  }
}

resource PrivateEndpoint 'Microsoft.Network/privateEndpoints@2025-07-01' = {
  name: 'myPrivateEndpoint-${environmentType}'
  location: location.primary
  properties: {
    subnet: {
      id: VirtualNetworkSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'myPrivateLinkServiceConnection'
        properties: {
          privateLinkServiceId: StorageAccount.id
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved by Bicep deployment'
          }
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}


output privateEndpointId string = PrivateEndpoint.id
