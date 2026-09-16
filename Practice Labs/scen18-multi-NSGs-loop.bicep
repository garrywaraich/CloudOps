var nsgproperties = [ for nsgs in range(0, 5): {
    name: 'nsg${nsgs}${uniqueString(resourceGroup().id)}'
    priority: 5000
    port: 80
    protocol: 'TCP'
    access: 'Allow'
    direction: 'Inbound'

  }
]

resource nsgsymbolic 'Microsoft.Network/networkSecurityGroups@2025-09-01' = [for i in nsgproperties: {
  name: 
  location:
  properties:{
    securityRules:[
      {
        name:
        properties:{
          access: 
          direction: 
          priority: 
          protocol: 
        }
      }
    ]
  }
}

NSG Name
Priority
Port
Access
