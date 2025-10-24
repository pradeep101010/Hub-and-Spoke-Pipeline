param location string = resourceGroup().location
param adminUsername string
param adminPassword string  // plain inline, not secure

// Deploy VNets (Hub-Spoke)
module vnets 'vnet.bicep' = {
  name: 'vnetModule'
  params: { location: location }
}

// VM in Spoke A
module vmA 'vm.bicep' = {
  name: 'vmAModule'
  params: {
    vmName: 'vmA'
    location: location
    subnetId: vnets.outputs.subnetAId
    vmSize: 'Standard_B1s'
    adminUsername: adminUsername
    adminPassword: adminPassword
    enableIpForwarding: false
  }
}

// VM in Hub B (IP forwarding enabled)
// Hub VM (IP forwarding enabled)
module vmB 'vm.bicep' = {
  name: 'vmBModule'
  params: {
    vmName: 'vmB'
    location: location
    subnetId: vnets.outputs.subnetBId
    vmSize: 'Standard_B1s'
    adminUsername: adminUsername
    adminPassword: adminPassword
    enableIpForwarding: true
  }
}

// Inject custom script extension to enable hub routing
module hubRouting 'hubVmRouting.bicep' = {
  name: 'hubRoutingModule'
  params: {
    vmName: vmB.outputs.vmId  // Pass VM name or resource id
    location: location
  }
  dependsOn: [
    vmB
  ]
}


// VM in Spoke C
module vmC 'vm.bicep' = {
  name: 'vmCModule'
  params: {
    vmName: 'vmC'
    location: location
    subnetId: vnets.outputs.subnetCId
    vmSize: 'Standard_B1s'
    adminUsername: adminUsername
    adminPassword: adminPassword
    enableIpForwarding: false
  }
}
