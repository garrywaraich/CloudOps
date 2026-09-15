// var env = [
//   'dev'
//   'test'
//   'prod'
// ]

var env = [
  {
    name: 'dev'
    sku: 'Standard_LRS'
    accessTier: 'Cool'
  }
  {
    name: 'test'
    sku: 'Standard_ZRS'
    accessTier: 'Cool'
  }
  {
    name: 'prod'
    sku: 'Standard_GRS'
    accessTier: 'Hot'
  }
]

param locations string = resourceGroup().location

resource stgacc 'Microsoft.Storage/storageAccounts@2026-04-01' = [for (stgenv, i) in env: {
  name: take('stg${stgenv.name}${uniqueString(resourceGroup().id)}', 24)
  location: locations
  sku: {
    name: stgenv.sku
  }
  kind: 'StorageV2'
  properties:{
    accessTier: stgenv.accessTier
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2025-09-01' = [for (vnetenv, i) in env: {
  name: 'vnet-${vnetenv.name}${uniqueString(resourceGroup().id)}'
  location: locations
  properties:{
    addressSpace:{
      addressPrefixes:[
        '10.${i}.0.0/16'
      ]
    }
    subnets:[
      {
        name: 'sub-${vnetenv.name}'
        properties:{
          addressPrefix: '10.${i}.${i+1}.0/24'
          networkSecurityGroup: {
            id: nsgsymbolic[i].id
          }
        }
      }
    ]
  }
}]

resource nsgsymbolic 'Microsoft.Network/networkSecurityGroups@2025-09-01' = [for (nsgenv, i) in env: {
  name: 'nsg-${nsgenv.name}${uniqueString(resourceGroup().id)}'
  location: locations
  properties:{
    securityRules:[
      {
        name: 'Allow ICMP'
        properties:{
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Icmp'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.${i}.0.0/16'
          sourcePortRange: '*'
          destinationPortRange: '*'
        }
      }
    ]
  } 
}]

output stginfo array = [for stgenvinfo in range(0, length(env)): {
  name: stgacc[stgenvinfo].name
  ID: stgacc[stgenvinfo].id
}]

output vnetinfo array = [for vnetenvinfo in range(0, length(env)): {
  name: vnet[vnetenvinfo].name
  ID: vnet[vnetenvinfo].id
}]

output nsginfo array = [for nsgenvinfo in range(0, length(env)): {
  customrules: nsgsymbolic[nsgenvinfo].properties.securityRules
  ID: nsgsymbolic[nsgenvinfo].id
}]
