targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location

// Variables
var firewallPolicyName = 'Heinrich_Policy'

// New Resources
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-05-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    threatIntelMode: 'Deny'
    sku: {
      tier: 'Standard'
    }
    dnsSettings: {
      enableProxy: true
    }
  }
}

// Outputs

output id string = firewallPolicy.id
output name string = firewallPolicy.name
