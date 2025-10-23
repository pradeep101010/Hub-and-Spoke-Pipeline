@description('VM Name')
param vmName string

@description('Location for the VM')
param location string = resourceGroup().location

@description('Subnet ID where VM will be deployed')
param subnetId string

@description('VM size')
param vmSize string = 'Standard_B2s'

@description('Admin username')
param adminUsername string

@description('Admin password')
@secure()
param adminPassword string

@description('Enable IP forwarding on the NIC?')
param enableIpForwarding bool = false

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: subnetId }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    enableIPForwarding: enableIpForwarding
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [ { id: nic.id } ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
  }
}

output vmId string = vm.id
output nicId string = nic.id
