@description('Location for the VNets')
param location string = resourceGroup().location

resource virtualNetwork1 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet1'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Vnet-1-Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}
resource virtualNetwork2 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet2'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '11.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Vnet-2-Subnet-1'
        properties: {
          addressPrefix: '11.0.0.0/24'
        }
      }
    ]
  }
}
resource virtualNetwork3 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet3'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '12.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Vnet-3-Subnet-1'
        properties: {
          addressPrefix: '12.0.0.0/24'
        }
      }
    ]
  }
}


// A <=> B peering
resource peeringAtoB 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'virtualNetwork1/peerAtoB'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: virtualNetwork2.id
    }
  }
}
resource peeringBtoA 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'virtualNetwork2/peerBtoA'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: virtualNetwork1.id
    }
  }
}


//B <=> C peering
resource peeringBtoC 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'virtualNetworkB/peerBtoC'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: virtualNetwork3.id
    }
  }
}
resource peeringCtoB 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: 'virtualNetworkC/peerCtoB'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: virtualNetwork2.id
    }
  }
}


output vnet1Name string = 'vnet1'
output vnet2Name string = 'vnet2'
output vnet3Name string = 'vnet3'
output vnet1Subnetname string = 'Vnet-1-Subnet-1'
output vnet2Subnetname string = 'Vnet-2-Subnet-1'
output vnet3Subnetname string = 'Vnet-3-Subnet-1'
