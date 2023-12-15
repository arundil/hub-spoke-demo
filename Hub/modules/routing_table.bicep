targetScope = 'resourceGroup'

// Parameters

@allowed([
  'We'
])
param locationShort string

param routingTableName string
param destinations array
param labels array

// Variables

var vHUBName = 'Az${locationShort}VHUB'
var fwRG = 'HUB'

// Dependencies
resource vhub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: vHUBName
}

resource firewall 'Microsoft.Network/azureFirewalls@2022-01-01' existing = {
  name: 'Heinrich'
  scope: resourceGroup(fwRG)
}

// Resources
resource routingTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-05-01' = {
  name: 'Default'
  parent: vhub
  properties: {
    labels: labels
    routes: [
      {
        destinations: destinations
        destinationType: 'CIDR'
        name: routingTableName
        nextHop: firewall.id
        nextHopType: 'ResourceId'
      }
    ]
  }
}

output routingTableId string = routingTable.id
