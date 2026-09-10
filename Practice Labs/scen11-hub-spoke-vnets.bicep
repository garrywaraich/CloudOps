param locations string = resourceGroup().location

// param vnets array = [
//   '10.1.0.0/16'
//   '10.2.0.0/16'
//   '10.3.0.0/16'
// ]

var hubspoke = {
    hub: {
      name: 'hubvnet'
      addressPrefix: '10.1.0.0/16'
    }
    spoke1: {
      name: 'spoke-vnet-1'
      addressPrefix: '10.2.0.0/16'
    }
    spoke2: {
      name: 'spoke-vnet-2'
      addressPrefix: '10.3.0.0/16'
    }
}

resource hubvnetcreate 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: hubspoke.hub.name
  location: resourceGroup().location
  properties:{
    addressSpace:{
      addressPrefixes:[
        hubspoke.hub.addressPrefix
      ]   
    }
  }
}

resource spoke1vnetcreate 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: hubspoke.spoke1.name
  location: resourceGroup().location
  properties:{
    addressSpace:{
      addressPrefixes:[
        hubspoke.spoke1.addressPrefix
      ]   
    }
  }
}

resource spoke2vnetcreate 'Microsoft.Network/virtualNetworks@2025-07-01' = {
  name: hubspoke.spoke2.name
  location: resourceGroup().location
  properties:{
    addressSpace:{
      addressPrefixes:[
        hubspoke.spoke2.addressPrefix
      ]   
    }
  }
}

resource hubtospoke1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  name: 'hub-spoke1'
  parent: hubvnetcreate
  properties:{
    remoteVirtualNetwork: {
      id: spoke1vnetcreate.id
    }
  }
}
resource spoke1tohub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  name: 'spoke1-hub'
  parent: spoke1vnetcreate
  properties:{
    remoteVirtualNetwork: {
      id: hubvnetcreate.id
    }
  }
}

resource hubtospoke2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  name: 'hub-spoke2'
  parent: hubvnetcreate
  properties:{
    remoteVirtualNetwork: {
      id: spoke2vnetcreate.id
    }
  }
}
resource spoke2tohub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-07-01' = {
  name: 'spoke2-hub'
  parent: spoke2vnetcreate
  properties:{
    remoteVirtualNetwork: {
      id: hubvnetcreate.id
    }
  }
}

output hubvnetID string = hubvnetcreate.id
output spokevnet1ID string = spoke1vnetcreate.id
output spokevnet2ID string = spoke2vnetcreate.id

output peeringsummary object = {
  hubtospoke1: hubtospoke1.properties.peeringState
  hubtospoke2: hubtospoke2.properties.peeringState
  spoke1tohub: spoke1tohub.properties.peeringState
  spoke2tohub: spoke2tohub.properties.peeringState
}
