targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location

@allowed([
  'We'
])
param locationShort string

param firewallPolicyId string
param virtualHubId string

// Variables
var firewallName = 'Heinrich'

resource firewall 'Microsoft.Network/azureFirewalls@2022-01-01' = {
  name: firewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    hubIPAddresses: {
      publicIPs: {
        addresses: []
        count: 1
      }
    }
    virtualHub: {
      id: virtualHubId
    }
    firewallPolicy: {
      id: firewallPolicyId
    }
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}

resource firewallLogWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'Az${locationShort}LogAFW'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource firewallDiagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Diagnostic-Logs'
  scope: firewall
  properties: {
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
      }
    ]
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
      {
        category: 'AzureFirewallDnsProxy'
        enabled: true
      }
      {
        category: 'AZFWNetworkRule'
        enabled: true
      }
      {
        category: 'AZFWApplicationRule'
        enabled: true
      }
      {
        category: 'AZFWNatRule'
        enabled: true
      }
      {
        category: 'AZFWThreatIntel'
        enabled: true
      }
      {
        category: 'AZFWIdpsSignature'
        enabled: true
      }
      {
        category: 'AZFWDnsQuery'
        enabled: true
      }
      {
        category: 'AZFWFqdnResolveFailure'
        enabled: true
      }
      {
        category: 'AZFWNetworkRuleAggregation'
        enabled: true
      }
      {
        category: 'AZFWApplicationRuleAggregation'
        enabled: true
      }
      {
        category: 'AZFWNatRuleAggregation'
        enabled: true
      }
    ]
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: firewallLogWorkspace.id
  }
}

// Outputs
output firewallResourceId string = firewall.id
output firewallIngressIP string = firewall.properties.hubIPAddresses.publicIPs.addresses[0].address
