targetScope = 'resourceGroup'

// Parameters
//param projectName string
param location string = resourceGroup().location

// @allowed([
//   'We'
// ])
// param locationShort string

// @allowed([
//   'DEV'
//   'TEST'
//   'PROD'
// ])
// param zone string
param vnetAddressPrefix string
param vnetName string
param subnets array

// Resources
resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
    subnets: subnets
  }
}
