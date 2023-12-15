// =========== network-ipgroups.bicep ===========
targetScope = 'resourceGroup'

// Common Parameters
param location string
param locationShort string

// Local Parameters
param MarioSubnetPrefix array
param IvanSubnetPrefix array
param GunterSubnetPrefix array

param bastionSubnetPrefix array

var ipGroups = [
  {
    name: 'Az${locationShort}IPGMario'
    ipAddresses: MarioSubnetPrefix
  }
  {
    name: 'Az${locationShort}IPGIvan'
    ipAddresses: IvanSubnetPrefix
  }
  {
    name: 'Az${locationShort}IPGGunter'
    ipAddresses: GunterSubnetPrefix
  }
  {
    name: 'Az${locationShort}IPGBastion'
    ipAddresses: bastionSubnetPrefix
  }
]

// Resources
@batchSize(1)
module ipGroupModule '../../modules/ip_groups.bicep' = [for ipGroup in ipGroups: {
  name: '${ipGroup.name}ipGroup'
  params: {
    ipGroups: ipGroup
    location: location
  }
}]
