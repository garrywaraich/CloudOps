param vnetproperties object = {
  name: 'vnet-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  prefix: '10.0.0.0/16'
}

param subnetproperties object = {
  name: 'subnet-${vnetproperties.name}'
  prefix: '10.0.1.0/24'
}

param nsgproperties object = {
  name: 'nsg-${subnetproperties.name}'
  location: 'eastus'
  secrulename: 'Allow 80 port'
}

var nicproperties = {
  name: 'nic-${vmproperties.name}'
  location: vnetproperties.location
  nicType: 'Standard'
}

@secure()
param adminPassword string

param adminUsername string

var vmproperties = {
  name: 'dev-linux'
  location: vnetproperties.location
  nicType: 'Standard'
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: vnetproperties.name
  location: vnetproperties.location
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetproperties.prefix
      ]
    }
  }
}

resource devsubnet 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: subnetproperties.name
  parent: vnet
  properties:{
    addressPrefix: subnetproperties.prefix
  }
}

resource devNSG 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  name: nsgproperties.name
  location: nsgproperties.location
  properties:{
    securityRules:[
      {
        name: nsgproperties.secrulename
        properties:{
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          sourceAddressPrefix: 'Any'
          destinationAddressPrefix: devVM.id
          destinationPortRange: '80'
          sourcePortRange: 'Any'
        }
      }
    ]
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2025-07-01' = {
  name: nicproperties.name
  location: nicproperties.location
  properties:{
    nicType: nicproperties.nicType
    ipConfigurations:[
      {
        name: 'devVM-ip'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          subnet:{
            id: devsubnet.id
          }
        }
      }
    ]
  }
}


resource devVM 'Microsoft.Compute/virtualMachines@2026-03-01' = {
  name: vmproperties.name
  location: vmproperties.location
  properties:{
    hardwareProfile:{
      vmSize:'Standard_A1'
    }
    networkProfile:{
      networkInterfaces:[
        {
          id: nic.id
        }
      ]
    }
    osProfile:{
      adminPassword: adminPassword
      adminUsername: adminUsername
      computerName: 'mymachine'
      linuxConfiguration:{
        disablePasswordAuthentication: false
      }
    }
    storageProfile:{
      imageReference:{
        offer: 'UbuntuServer'
        publisher: 'Canonical'
        sku: '22.04-LTS'
        version: 'latest'
      }
      osDisk:{
        name: 'myosdisk'
        createOption: 'FromImage'
        diskSizeGB: 100
        caching: 'ReadWrite'
        osType:'Linux'
      }
    }
  }
}
