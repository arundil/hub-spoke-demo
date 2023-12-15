targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location
param locationShort string
param routes array
param projectName string
param purpose string
param zone string

resource networkRouteTables 'Microsoft.Network/routeTables@2023-04-01' = {
  name: 'Az${locationShort}UDR${purpose}${projectName}${zone}'
  location: location
  properties: {
    routes: [for route in routes: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        nextHopType: route.nextHopType
      }
    }]
  }
}
