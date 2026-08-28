@description('This script will deploy virtual network  and create subnet in each of the environments listed below')
param environment array = [
  'prod'
  'dev'
  'test'
]

var AddressSpace = '10.0.0.0/16'

@description('Define subnet properties like name and ipaddress to easily embed into resource definition')
param subnets array = [
  {
    name: 'frontend'
    prefix: '10.0.1.0/24'
  }
  {
    name: 'backend'
    prefix: '10.0.2.0/24'
  }
]

@description('For each listed item in above parameter, it will create below resource')
var subnetdefine = [for item in subnets: {
  name: item.name
  properties: {
    addressPrefix: item.prefix
  }
} ]

param locations string = resourceGroup().location

resource vnetsymbolic 'Microsoft.Network/virtualNetworks@2025-07-01' = [for envtype in environment: {
  name: 'vnet-${envtype}'
  location: locations
  properties: {
    addressSpace: {
      addressPrefixes: [
        AddressSpace
      ]
    }
    subnets: subnetdefine
  }
}]

@description('Alright, I went too advanced with my code than the requirement as I could not produce subnet IDs but I like to keep this code and probably built another one which is easier to get output needed.')
output vnetoutput array = [for i in range(0, length(environment)): {
  name: vnetsymbolic[i].name
  id: vnetsymbolic[i].id
  subID: vnetsymbolic[i].properties.subnets
}]
