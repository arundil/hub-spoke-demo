// =========== network-vnets.bicep ===========

targetScope = 'resourceGroup'

// Common Parameters
param location string
param locationShort string

// Local Parameters
param MarioAddressPrefix string
param IvanAddressPrefix string
param GunterAddressPrefix string

// Mario Vnet
module vnet_Mario '../../modules/coreservices-network/vnet.bicep' = {
  name: 'vNETMarioModule'
  params: {
    location: location
    vnetAddressPrefix: MarioAddressPrefix
    vnetName: 'Az${locationShort}MarioVNet'
    subnets: [
      {
        name: 'Az${locationShort}SNMario'
        properties: {
          addressPrefix: MarioAddressPrefix
        }
      }
    ]
  }
}

// Ivan Vnet
module vnet_Ivan '../../modules/coreservices-network/vnet.bicep' = {
  name: 'vNETIvanModule'
  params: {
    location: location
    vnetAddressPrefix: IvanAddressPrefix
    vnetName: 'Az${locationShort}IvanVNet'
    subnets: [
      {
        name: 'Az${locationShort}SNIvan'
        properties: {
          addressPrefix: IvanAddressPrefix
        }
      }
    ]
  }
}

// Günter Vnet
module vnet_Guenter '../../modules/coreservices-network/vnet.bicep' = {
  name: 'vNETGunterModule'
  params: {
    location: location
    vnetAddressPrefix: GunterAddressPrefix
    vnetName: 'Az${locationShort}GunterVNet'
    subnets: [
      {
        name: 'Az${locationShort}SNGunter'
        properties: {
          addressPrefix: GunterAddressPrefix
        }
      }
    ]
  }
}
