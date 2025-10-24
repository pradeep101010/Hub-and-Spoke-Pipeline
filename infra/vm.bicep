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

  // Nested extension: remove location
  resource enableForwarding 'extensions@2021-07-01' = if (enableIpForwarding) {
    name: 'EnableIPForwarding'
    properties: {
      publisher: 'Microsoft.Azure.Extensions'
      type: 'CustomScript'
      typeHandlerVersion: '2.1'
      autoUpgradeMinorVersion: true
      settings: {
        fileUris: []
        commandToExecute: '''
        #!/bin/bash
        # Enable IP forwarding
        sudo sysctl -w net.ipv4.ip_forward=1
        echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

        # Enable NAT for forwarded traffic
        sudo iptables -t nat -A POSTROUTING -j MASQUERADE
        sudo iptables -A FORWARD -j ACCEPT

        # Open ICMP for ping
        sudo iptables -I INPUT -p icmp -j ACCEPT
        sudo iptables -I OUTPUT -p icmp -j ACCEPT
      '''
      }
    }
    location: location
  }
}



output vmId string = vm.id
output nicId string = nic.id
output vmPrivateIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
