param subnets array = [
  {
    name: 'subnet1'
    AddressPrefix: '10.0.1.0/24'
  }
  {
    name: 'subnet2'
    AddressPrefix: '10.0.2.0/24'
  }
]

var subnetconf = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefixes: [
      subnet.AddressPrefix
    ]
  }
} ]

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: 'vnet-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: subnetconf
  }
}

output vnetID string = vnet.id

@description('subnet IDs follow predictable Azure format, so it can be constructed using vnet ID and subnet name')
output subnetinfo array = [for item in subnets: {
  name: item.name
  subnetID: '${vnet.id}/subnets/${item.name}'
}]
