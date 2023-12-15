// =========== network-peering.bicep ===========
// Peers all the existigs Vnets to the HUB
//
// Dependencies: Vnets, Virtual WAN
// 

targetScope = 'resourceGroup'

// Common Parameters

param locationShort string

var vhubRG = 'HUB'
var vnetsRG = 'Spokes'
var bastionRG = 'Bastion_Spoke'
var vHUBName = 'Az${locationShort}VHUB'

// DealerHub peerings
var hubBastionPeeringName = 'Az${locationShort}hubToBastion'
var hubMarioPeeringName = 'Az${locationShort}hubToMario'
var hubIvanPeeringName = 'Az${locationShort}hubToIvan'
var hubGunterPeeringName = 'Az${locationShort}hubToGunter'

//Existing Resources
resource vhub 'Microsoft.Network/virtualHubs@2022-05-01' existing = {
  scope: resourceGroup(vhubRG)
  name: vHUBName
}

// DealerHUB
resource vnetMario 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}MarioVNet'
  scope: resourceGroup(vnetsRG)
}

resource vnetIvan 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}IvanVNet'
  scope: resourceGroup(vnetsRG)
}

resource vnetGunter 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}GunterVNet'
  scope: resourceGroup(vnetsRG)
}

resource vnetBastion 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}BastionVNet'
  scope: resourceGroup(bastionRG)
}

// Resources

module privateTrafficRoutingTable '../../modules/routing_table.bicep' = {
  name: 'privateRoutingTable'
  params: {
    routingTableName: 'public_traffic'
    destinations: [
      '0.0.0.0/0'
      '10.0.0.0/8'
      '172.16.0.0/12'
      '192.168.0.0/16'
    ]
    labels: [
      'default'
    ]
    locationShort: locationShort
  }
  scope: resourceGroup(vhubRG)
}

resource NoneRoutingTable 'Microsoft.Network/virtualHubs/hubRouteTables@2022-05-01' existing = {
  name: 'noneRouteTable'
  parent: vhub
}

// Modules

module hubMarioPeering '../../modules/hub_vnet_peering.bicep' = {
  name: 'HubMarioVnetPeering'
  params: {
    vHUBName: vHUBName
    internetSecurity: true
    noneRoutingTableID: NoneRoutingTable.id
    peeringName: hubMarioPeeringName
    publicRoutingTableID: privateTrafficRoutingTable.outputs.routingTableId
    VnetID: vnetMario.id
  }
  scope: resourceGroup(vhubRG)
}

module hubIvanPeering '../../modules/hub_vnet_peering.bicep' = {
  name: 'HubIvanVnetPeering'
  params: {
    vHUBName: vHUBName
    internetSecurity: true
    noneRoutingTableID: NoneRoutingTable.id
    peeringName: hubIvanPeeringName
    publicRoutingTableID: privateTrafficRoutingTable.outputs.routingTableId
    VnetID: vnetIvan.id
  }
  scope: resourceGroup(vhubRG)
}

module hubGunterPeering '../../modules/hub_vnet_peering.bicep' = {
  name: 'HubGunterVnetPeering'
  params: {
    vHUBName: vHUBName
    internetSecurity: true
    noneRoutingTableID: NoneRoutingTable.id
    peeringName: hubGunterPeeringName
    publicRoutingTableID: privateTrafficRoutingTable.outputs.routingTableId
    VnetID: vnetGunter.id
  }
  scope: resourceGroup(vhubRG)
}

module hubBastionPeering '../../modules/hub_vnet_peering.bicep' = {
  name: 'HubBastionVnetPeering'
  params: {
    vHUBName: vHUBName
    internetSecurity: true
    noneRoutingTableID: NoneRoutingTable.id
    peeringName: hubBastionPeeringName
    publicRoutingTableID: privateTrafficRoutingTable.outputs.routingTableId
    VnetID: vnetBastion.id
  }
  scope: resourceGroup(vhubRG)
}
