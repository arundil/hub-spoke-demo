// =========== coreservices-network-bastion.bicep ===========
// It creates a VNet + subnet exclusively for Bastion Hosts.
// Also creates Bation hosts service + public IP address. 
// This network will be publicly accesible as Bastion needs a 
// public IP to work. Due Microsoft recomedation it must not be "Firewalled".
// It contains NSG instead to limitate the trafict.
//
// Dependencies: 
// None

targetScope = 'resourceGroup'

// Common Parameters
param location string
param locationShort string

// Local Parameters
param bastionAddressPrefix string

// Resources

// Azure Bastion Vnet
module vnet_bastion '../../modules/vnet_bastion.bicep' = {
  name: 'vNETBastionModule'
  params: {
    location: location
    locationShort: locationShort
    bastionAddressPrefix: bastionAddressPrefix
  }
}

// Azure Bastion
module bastion '../../modules/bastion.bicep' = {
  name: 'bastionServiceModule'
  dependsOn: [
    vnet_bastion
  ]
  params: {
    location: location
    locationShort: locationShort
    virtualNetworkName: vnet_bastion.outputs.bastionVnetName
  }
}
