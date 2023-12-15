targetScope = 'resourceGroup'

// Parameters

// @allowed([
//   'We'
// ])
// param locationShort string

param firewallPolicyName string

// Variables

// Existing Resources

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-05-01' existing = {
  name: firewallPolicyName
}

// resource ipGroupMario 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGMario'
// }
// resource ipGroupIvan 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGIvan'
// }
// resource ipGroupGunter 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGGunter'
// }
// resource ipGroupBastion 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGBastion'
// }

//L4 Firewall Rules
resource networkFirewallPolicyRules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-05-01' = {
  name: 'NetworkRuleCollectionGroup'
  parent: firewallPolicy
  properties: {
    priority: 200
    ruleCollections: [
      // {
      //   name: 'Allow-AKS-VirtualMachines'
      //   description: 'Traffic from AKS network to Virtual Machines.'
      //   sourceIpGroups: [
      //     ipGroupIvan.id
      //   ]
      //   ruleType: 'NetworkRule'
      //   destinationIpGroups: [
      //     ipGroupMario.id
      //   ]
      //   ipProtocols: [
      //     'TCP'
      //   ]
      //   destinationPorts: [
      //     '9999'
      //   ]
      // }
    ]
  }
}
