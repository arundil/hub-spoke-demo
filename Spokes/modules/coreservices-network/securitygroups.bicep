targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location
param locationShort string
param networkSecurityRules array
param projectName string
param purpose string
param zone string

resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'Az${locationShort}NSG${purpose}${projectName}${zone}'
  location: location
  properties: {
    securityRules: [for networkSecurityRule in networkSecurityRules: {
      name: networkSecurityRule.name
      properties: {
        description: networkSecurityRule.description
        protocol: networkSecurityRule.protocol
        sourcePortRange: contains(networkSecurityRule, 'sourcePortRange') ? networkSecurityRule.sourcePortRange : null
        destinationPortRange: contains(networkSecurityRule, 'destinationPortRange') ? networkSecurityRule.destinationPortRange : null
        sourceAddressPrefix: contains(networkSecurityRule, 'sourceAddressPrefix') ? networkSecurityRule.sourceAddressPrefix : null
        destinationAddressPrefix: contains(networkSecurityRule, 'destinationAddressPrefix') ? networkSecurityRule.destinationAddressPrefix : null
        access: networkSecurityRule.access
        priority: networkSecurityRule.priority
        direction: networkSecurityRule.direction
        sourcePortRanges: contains(networkSecurityRule, 'sourcePortRanges') ? networkSecurityRule.sourcePortRanges : null
        destinationPortRanges: contains(networkSecurityRule, 'destinationPortRanges') ? networkSecurityRule.destinationPortRanges : null
        sourceAddressPrefixes: contains(networkSecurityRule, 'sourceAddressPrefixes') ? networkSecurityRule.sourceAddressPrefixes : null
        destinationAddressPrefixes: contains(networkSecurityRule, 'destinationAddressPrefixes') ? networkSecurityRule.destinationAddressPrefixes : null
      }
    }]
  }
}
