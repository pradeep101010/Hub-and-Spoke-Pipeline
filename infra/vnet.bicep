@description('Location for the VNets')
param location string = resourceGroup().location

// VNet 1 (Spoke A)
resource vnet1 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'Pradeep-vnet1'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      {
        name: 'Vnet-1-Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          // IP forwarding enabled on the spoke subnet is optional
          // for VMs to forward traffic if they act as routers
          // But usually hub subnet needs it
        }
      }
    ]
  }
}

// VNet 2 (Hub)
resource vnet2 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'Pradeep-vnet2'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['11.0.0.0/16'] }
    subnets: [
      {
        name: 'Vnet-2-Subnet-1'
        properties: {
          addressPrefix: '11.0.0.0/24'
          // Enable IP forwarding so hub can route traffic between spoke
        }
      }
    ]
  }
}

// VNet 3 (Spoke C)
resource vnet3 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'Pradeep-vnet3'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['12.0.0.0/16'] }
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

// Peering: A <=> Hub
resource peerAtoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: vnet1
  name: 'peerAtoHub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: { id: vnet2.id }
  }
}
resource peerHubToA 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: vnet2
  name: 'peerHubToA'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: { id: vnet1.id }
  }
}

// Peering: C <=> Hub
resource peerCtoHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: vnet3
  name: 'peerCtoHub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: { id: vnet2.id }
  }
}
resource peerHubToC 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: vnet2
  name: 'peerHubToC'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: { id: vnet3.id }
  }
}

// Outputs
output vnet1Name string = vnet1.name
output vnet2Name string = vnet2.name
output vnet3Name string = vnet3.name
output vnet1SubnetName string = vnet1.properties.subnets[0].name
output vnet2SubnetName string = vnet2.properties.subnets[0].name
output vnet3SubnetName string = vnet3.properties.subnets[0].name
