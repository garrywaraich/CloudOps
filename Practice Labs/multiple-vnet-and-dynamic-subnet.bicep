param vnets array = [
  '10.0.0.0/16'
  '10.1.0.0/16'
  '10.2.0.0/16'
  '10.3.0.0/16'
  '10.4.0.0/16'
]

var subnetNames = [
  'frontend'
  'backend'
]

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = [for (vnetPrefix, index) in vnets: {
  name: 'vnet-${uniqueString(resourceGroup().id, vnetPrefix)}-${index}'
  location: resourceGroup().location
  properties: {
    addressSpace:{
      addressPrefixes:[
        vnetPrefix
      ]
    }
    subnets: [for (subname, i) in subnetNames: {
      name: 'subnet-${subname}'
      properties:{
        addressPrefix: '10.${index}.${i + 1}.0/24'
      }
    }]
  }
}]

output vnetIDs array = [for items in range(0, length(vnets)): {
  name: vnet[items].name
  ID: vnet[items].id
  addressPrefix: vnet[items].properties.addressSpace.addressPrefixes
}]
