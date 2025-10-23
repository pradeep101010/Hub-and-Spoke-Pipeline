param vmName string
param location string = resourceGroup().location
param subnetId string
param vmSize string = 'Standard_B1s'
param adminUsername string
param adminPassword string
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
    networkProfile: { networkInterfaces: [ { id: nic.id } ] }
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
output vmPrivateIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
