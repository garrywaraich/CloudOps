@description('This script include conditional deployment of Bastion host if environmentType is prod')
@allowed([
  'dev'
  'prod'
])

param environmentType string

@description('This will take input while deploying Bicep and deploy Bastion host only if environmentType is prod')
var deployBastion = environmentType == 'prod'

var vnetproperties = {
    name: 'vnet-${environmentType}-${uniqueString(resourceGroup().id)}'
    location: resourceGroup().location
    addressPrefix: '10.0.0.0/16'
}

var subnetproperties = {
    name: 'subnet1-${vnetproperties.name}'
    addressPrefix: '10.0.1.0/24'
}

var bastionproperties = {
    name: 'bastion-${vnetproperties.name}'
    location: vnetproperties.location
    sku: 'standard'
  }

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: vnetproperties.name
  location: vnetproperties.location
  properties: {
    addressSpace: {
      addressPrefixes:[
        vnetproperties.addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetproperties.name
        properties:{
          addressPrefix: subnetproperties.addressPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties:{
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

resource bastionpublicIP 'Microsoft.Network/publicIPAddresses@2025-07-01' = if (deployBastion) {
  name: 'bastionpip-${bastionproperties.name}'
  location: bastionproperties.location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  
}

resource bastion 'Microsoft.Network/bastionHosts@2025-07-01' = if (deployBastion) {
  name: bastionproperties.name
  location: bastionproperties.location
  sku:{
    name: bastionproperties.sku
  }
  properties:{
    ipConfigurations: [
      {
        name: 'ip-${bastionproperties.name}'
        properties:{
          publicIPAddress: {
            id: bastionpublicIP.id
          }
          subnet: {
            id: '${vnet.id}/subnets/AzureBastionSubnet'
          }
        }
      }
    ]
  }
}

var bastionsubnetID = '${vnet.id}/subnets/AzureBastionSubnet'

output vnetID string = vnet.id

output subnetBastionnetID string = deployBastion ? bastionsubnetID : ''
output subnetBastionaddress string = deployBastion ? vnet.properties.subnets[1].properties.addressPrefix : ''

output bastionID string = deployBastion ? bastion.id : 'Not deployed'

output bastionpip string = deployBastion ? (bastionpublicIP.properties.ipAddress ?? '') : ''
