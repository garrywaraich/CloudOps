var nsgNames = [ for i in range(0, 5): 'nsg${i}${uniqueString(resourceGroup().id)}']

var portsallowed = [
  20
  80
  443
]

var nsgrules = [for (port, i) in portsallowed: {
    name: 'allowPort-${port}'
    properties:{
      access: 'Allow'
      direction: 'Inbound'
      priority: 100 + i
      protocol: 'Tcp'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      sourcePortRange: '*'
      destinationPortRange: string(port)
    }
  }]

resource nsgsymbolic 'Microsoft.Network/networkSecurityGroups@2025-09-01' = [for nsgName in nsgNames: {
  name: nsgName
  location: resourceGroup().location
  properties:{
    securityRules: nsgrules
  }
}
] 

output nsginfo array = [
  for i in range(0, length(nsgNames)): {
    name: nsgsymbolic[i].name
    id: nsgsymbolic[i].id
    securityRules: nsgsymbolic[i].properties.securityRules
  }
]
