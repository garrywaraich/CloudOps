param locationAllowed array = [
  'eastus'
  'westus'
  'centralus'
]

param vnetName string
param subnetName string
param nsgName string
param nicName string
param virtualmachineName string

@secure()
param vmAdminUsername string

@secure()
param vmAdminPassword string

param vmhostname string

var resourceproperties = {
  vnet: {
      name: vnetName
      location: locationAllowed[1]
      AddressSpace: '10.0.0.0/16'
    }
  sub: {
      name: '${subnetName}-${vnetName}'
      AddressPrefix: '10.0.1.0/24'
    }
  nsg: {
      name: nsgName
      location: locationAllowed[1]
    }
  nic: {
      name: '${nicName}-${virtualmachineName}'
      location: locationAllowed[1]
    }
  vm: {
    name: virtualmachineName
    location: locationAllowed[1]
    vmsize: 'Standard_B1s'
    vmadminuser: vmAdminUsername
    vmadminpass: vmAdminPassword
    vmname: vmhostname
    vmimagefamily: 'UbuntuServer'
    vmimagepublisher: 'Canonical'
    vmimagesku: '16.04-LTS'
    vmimageversion: 'latest'
    vmosdiskname: 'myfirstOS-disk'
    }
}

resource Virtualnetsymb 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: resourceproperties.vnet.name
  location: resourceproperties.vnet.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        resourceproperties.vnet.AddressSpace
      ]
    }
  }
}

resource Subnetsymb 'Microsoft.Network/virtualNetworks/subnets@2025-07-01' = {
  name: resourceproperties.sub.name
  parent: Virtualnetsymb
  properties: {
    addressPrefix: resourceproperties.sub.AddressPrefix
    networkSecurityGroup: {
      id: NSGsymb.id
    }
  }
}

resource NSGsymb 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
  name: resourceproperties.nsg.name
  location: resourceproperties.nsg.location
}

resource NICsymb 'Microsoft.Network/networkInterfaces@2025-07-01' = {
  name: resourceproperties.nic.name
  location: resourceproperties.nic.location
  properties: {
    nicType: 'Standard'
    ipConfigurations: [
      {
        name: 'firstIPconf'
        properties: {
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          primary: true
          subnet: {
            id: Subnetsymb.id
          }
        }
      }
    ]
  }
}

resource vmsymb 'Microsoft.Compute/virtualMachines@2026-03-01' = {
  name: resourceproperties.vm.name
  location: resourceproperties.vm.location
  properties: {
    hardwareProfile: {
      vmSize: resourceproperties.vm.vmsize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NICsymb.id
          properties: {
            primary: true
          }
        }
      ]
    }
    osProfile: {
      adminPassword: resourceproperties.vm.vmadminpass
      adminUsername: resourceproperties.vm.vmadminuser
      computerName: resourceproperties.vm.vmname
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        offer: resourceproperties.vm.vmimagefamily
        publisher: resourceproperties.vm.vmimagepublisher
        sku: resourceproperties.vm.vmimagesku
        version: resourceproperties.vm.vmimageversion
      }
      osDisk: {
        createOption: 'FromImage'
        name: resourceproperties.vm.vmosdiskname
        caching: 'ReadWrite'
      }
    }
  }
}

output vmNam string = vmsymb.name
output nicID string = NICsymb.id
output subID string = Subnetsymb.id
output nsgID string = NSGsymb.id
