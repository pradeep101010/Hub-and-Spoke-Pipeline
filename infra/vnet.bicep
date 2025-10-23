@description('Location for the VNets')
param location string = resourceGroup().location

// --- VNets ---
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
          // routeTable assigned later
        }
      }
    ]
  }
}

// VNet 2 (Hub B)
resource vnet2 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'Pradeep-vnet2'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['11.0.0.0/16'] }
    subnets: [
      {
        name: 'Vnet-2-Subnet-1'
        properties: { addressPrefix: '11.0.0.0/24' }
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
          // routeTable assigned later
        }
      }
    ]
  }
}

// --- Peering ---
// A <=> Hub
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

// C <=> Hub
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

// --- Route Table ---
resource routeTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'HubB-RouteTable'
  location: location
  properties: {
    routes: [
      {
        name: 'RouteToC'
        properties: {
          addressPrefix: '12.0.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '11.0.0.4' // Hub VM private IP
        }
      }
      {
        name: 'RouteToA'
        properties: {
          addressPrefix: '10.0.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '11.0.0.4' // Hub VM private IP
        }
      }
    ]
  }
}
// --- Associate Route Table with Spoke A subnet ---
resource assocRouteA 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet1
  name: 'Vnet-1-Subnet-1'
  properties: {
    addressPrefix: vnet1.properties.subnets[0].properties.addressPrefix
    routeTable: {
      id: routeTable.id
    }
  }
}

// --- Associate Route Table with Spoke C subnet ---
resource assocRouteC 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet3
  name: 'Vnet-3-Subnet-1'
  properties: {
    addressPrefix: vnet3.properties.subnets[0].properties.addressPrefix
    routeTable: {
      id: routeTable.id
    }
  }
}

// --- Outputs for convenience ---
output subnetAId string = assocRouteA.id
output subnetBId string = vnet2.properties.subnets[0].id
output subnetCId string = assocRouteC.id
output routeTableId string = routeTable.id
