// =========== vwan-VWAN.bicep ===========
// It created the VWAN, VHUB and the VPNGateway
// The VPN Gateway is attached to the VHUB once this is created.
//
// Dependencies:
// None

targetScope = 'resourceGroup'

// Common Parameters
param location string
param locationShort string

// Local Parameters
param vHUBaddressPrefix string

// Resources

// Azure Virtual WAN & Virtual HUB
module vwan_vhub '../../modules/vwan_vhub.bicep' = {
  name: 'vWAN-vHUBModule'
  params: {
    location: location
    locationShort: locationShort
    vHUBaddressPrefix: vHUBaddressPrefix
  }
}
