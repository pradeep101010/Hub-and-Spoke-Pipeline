@description('VM name to apply routing script')
param vmName string
@description('Resource group location')
param location string = resourceGroup().location

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' existing = {
  name: vmName
}
resource customScript 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vm
  name: 'EnableIPForwarding'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [] // no external script file needed
      commandToExecute: '''
        #!/bin/bash
        # Enable IP forwarding
        sudo sysctl -w net.ipv4.ip_forward=1
        # Persist after reboot
        echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
        # Enable simple NAT for traffic forwarding
        sudo iptables -t nat -A POSTROUTING -j MASQUERADE
        sudo iptables -A FORWARD -j ACCEPT
      '''
    }
  }
}

output extensionId string = customScript.id
