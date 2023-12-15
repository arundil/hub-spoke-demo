targetScope = 'resourceGroup'

// Parameters
param ipGroups object
param location string = resourceGroup().location

resource ipGroupDealerHUB 'Microsoft.Network/ipGroups@2021-05-01' = {
  name: ipGroups.name
  location: location
  properties: {
    ipAddresses: ipGroups.ipAddresses
  }
}
