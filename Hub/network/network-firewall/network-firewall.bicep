// =========== network-firewall.bicep ===========
// It creates FW policy.
// Also it creates the FW and it public IP address and attached it 
// to the VHUB in VWAN.
//
// Dependencies:
// VWAN 
// IP Groups

targetScope = 'resourceGroup'

// Common Parameters
param location string
param locationShort string

// Variables
var workbookCharts = loadJsonContent('charts/fwcharts.json')
var workbookChartsToString = string(workbookCharts)

// Resources
resource vhub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: 'Az${locationShort}VHUB'
}

// Firewall Policy
module firewallPolicy '../../modules/firewall-policy.bicep' = {
  name: 'firewallPolicyModule'
  params: {
    location: location
  }
}

// Firewall
module firewall '../../modules/firewall.bicep' = {
  name: 'firewallModule'
  params: {
    location: location
    locationShort: locationShort
    firewallPolicyId: firewallPolicy.outputs.id
    virtualHubId: vhub.id
  }
}

module firewallPolicyApplicationRules '../../modules/firewall-application-rules.bicep' = {
  name: 'firewallApplicationRulesModule'
  dependsOn: [
    firewall
  ]
  params: {
    firewallPolicyName: firewallPolicy.outputs.name
    // locationShort: locationShort
  }
}

module firewallPolicyNetworkRules '../../modules/firewall-network-rules.bicep' = {
  name: 'firewallPolicyNetworkRulesModule'
  dependsOn: [
    firewallPolicyApplicationRules
  ]
  params: {
    firewallPolicyName: firewallPolicy.outputs.name
    // locationShort: locationShort
  }
}

module firewallWorkbook '../../modules/workbook.bicep' = {
  name: 'firewallWorkbookModule'
  params: {
    workbookPurposeName: 'FirewallMonitoring'
    locationShort: locationShort
    location: location
    workbookSourceId: firewall.outputs.firewallResourceId
    workbookCharts: workbookChartsToString
  }
}
