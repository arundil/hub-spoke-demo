// =========== Resource-groups.bicep ===========
// It creates the resources groups in Azure
// where all the Network resources will be placed
// for Management Subscription

targetScope = 'subscription'

param location string

// Network Resources Groups
resource Hub_Spoke_RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'HUB'
  location: location
  properties: {}
}

resource Spoke_Bastion_RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'Bastion_Spoke'
  location: location
  properties: {}
}
