
targetScope = 'resourceGroup'

// Parameters

param vHUBName string

param VnetID string
param publicRoutingTableID string
param noneRoutingTableID string
param peeringName string
param internetSecurity bool

//Variables


resource vhub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  name: vHUBName
}

resource hubVnetPeering 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2022-01-01' = {
  name: peeringName
  parent: vhub
  properties: {
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: internetSecurity
    remoteVirtualNetwork: {
      id: VnetID
    }
    routingConfiguration:{
      associatedRouteTable:{
        id: publicRoutingTableID
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: noneRoutingTableID
          }
        ]
      }
      vnetRoutes: {
        staticRoutes: []
      }
    }
  }
}
