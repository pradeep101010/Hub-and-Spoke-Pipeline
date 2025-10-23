@description('Location for all resources')
param location string = resourceGroup().location

@description('Admin username for all VMs')
param adminUsername string

@description('Admin password for all VMs')
@secure()
param adminPassword string

// Deploy VNets (A, B, C)
module vnets 'vnet.bicep' = {
  name: 'vnetsModule'
  params: {
    location: location
  }
}

// Deploy VM in VNet A
module vmA 'vm.bicep' = {
  name: 'vmAModule'
  params: {
    vmName: 'VM-A'
    location: location
    subnetId: vnets.outputs.vnet1SubnetName
    adminUsername: adminUsername
    adminPassword: adminPassword
    enableIpForwarding: false
  }
}

// Deploy VM in VNet B (Hub) with IP forwarding enabled
module vmB 'vm.bicep' = {
  name: 'vmBModule'
  params: {
    vmName: 'VM-B'
    location: location
    subnetId: vnets.outputs.vnet2SubnetName
    adminUsername: adminUsername
    adminPassword: adminPassword
    enableIpForwarding: true
  }
}

// Deploy VM in VNet C
module vmC 'vm.bicep' = {
  name: 'vmCModule'
  params: {
    vmName: 'VM-C'
    location: location
    subnetId: vnets.outputs.vnet3SubnetName
    adminUsername: adminUsername
    adminPassword: adminPassword
    enableIpForwarding: false
  }
}
