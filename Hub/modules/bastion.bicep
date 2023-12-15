targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location

@allowed([
  'We'
])
param locationShort string

param virtualNetworkName string

// Variables
var bastionName = 'Az${locationShort}BA'
var bastionIPAdressName = 'Az${locationShort}PIPBA'

// Resources
resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  name: '${virtualNetworkName}/AzureBastionSubnet'
}

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: bastionIPAdressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-05-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    enableFileCopy: true
    enableIpConnect: true
    enableTunneling: true
    ipConfigurations: [
      {
        name: 'IpConfiguration'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}
