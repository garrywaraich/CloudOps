param locations string= resourceGroup().location

param vnetconfig array = [
  {
    name: 'vnet-prod'
    addressSpace: '10.1.0.0/16'

    subnets: [
      {
        name: 'subnet1'
        prefix: '10.1.1.0/24'
      }
      {
        name: 'subnet2'
        prefix: '10.1.2.0/24'
      }
    ]
  }
  {
    name: 'vnet-dev'
    addressSpace: '10.2.0.0/16'

    subnets: [
      {
        name: 'subnet1'
        prefix: '10.2.1.0/24'
      }
      {
        name: 'subnet2'
        prefix: '10.2.2.0/24'
      }
    ]
  }
  {
    name: 'vnet-test'
    addressSpace: '10.3.0.0/16'

    subnets: [
      {
        name: 'subnet1'
        prefix: '10.3.1.0/24'
      }
      {
        name: 'subnet2'
        prefix: '10.3.2.0/24'
      }
    ]
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = [for item in vnetconfig: {
  name: item.name
  location: locations
  properties: {
    addressSpace:{
      addressPrefixes: [
        item.addressSpace
      ]
    }
    subnets: [
      for subnet in item.subnets: {
        name: subnet.name
        properties:{
          addressPrefix: subnet.prefix
        }
      }
    ]
  }
}]

output vnetID array = [
  for i in range(0, length(vnetconfig)): {
    name: vnet[i].name
    vnetID: vnet[i].id
    subnetID: vnet[i].properties.subnets[0].id
  }
]

