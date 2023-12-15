targetScope = 'resourceGroup'

param privateDnsZone object

// Resources

resource privateDnsZoneResource 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZone.name
  location: 'global'
  properties: {}

  resource virtualNetworkLink 'virtualNetworkLinks' = [for virtualNetworkLink in privateDnsZone.virtualNetworksLinks: {
    name: virtualNetworkLink.virtualNetworkLinkName
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: virtualNetworkLink.virtualNetworkLinkId
      }
    }
  }]
}
