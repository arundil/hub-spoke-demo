targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location

@allowed([
  'We'
])
param locationShort string

param vHUBaddressPrefix string

// Variables
var vWANName = 'Az${locationShort}VWAN'
var vHUBName = 'Az${locationShort}VHUB'

resource vwan 'Microsoft.Network/virtualWans@2022-01-01' = {
  name: vWANName
  location: location
  properties: {
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    type: 'Standard'
  }
}

resource vhub 'Microsoft.Network/virtualHubs@2022-05-01' = {
  name: vHUBName
  location: location
  properties: {
    addressPrefix: vHUBaddressPrefix
    virtualWan: {
      id: vwan.id
    }
  }
}
