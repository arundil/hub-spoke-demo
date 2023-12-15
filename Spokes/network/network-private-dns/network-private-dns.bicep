// =========== coreservices-dns.bicep ===========
// It contains all the private DNS zones and Vnet links.
//
// Dependencies: 
// Vnets

targetScope = 'resourceGroup'

// Common Parameters
param projectName string
param locationShort string
param zone string

// Variables
var virtualNetworkResourceGroup = 'RG_${zone}_Network_VNETS'

var privateDnsZones = [
  {
    name: 'Az${locationShort}ASE${projectName}${zone}.appserviceenvironment.net'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkVirtualMachines.id
        virtualNetworkLinkName: virtualNetworkVirtualMachines.name
      }
      {
        virtualNetworkLinkId: virtualNetworkStorages.id
        virtualNetworkLinkName: virtualNetworkStorages.name
      }
    ]
  }
  {
    name: 'privatelink.azurewebsites.net'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.azconfig.io'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkVirtualMachines.id
        virtualNetworkLinkName: virtualNetworkVirtualMachines.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAzureKubernetesService.id
        virtualNetworkLinkName: virtualNetworkAzureKubernetesService.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAppServices.id
        virtualNetworkLinkName: virtualNetworkAppServices.name
      }
    ]
  }
  {
    name: 'privatelink.mongo.cosmos.azure.com'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.redis.cache.windows.net'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkAzureKubernetesService.id
        virtualNetworkLinkName: virtualNetworkAzureKubernetesService.name
      }
    ]
  }
  {
    name: 'privatelink.servicebus.windows.net'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkAzureKubernetesService.id
        virtualNetworkLinkName: virtualNetworkAzureKubernetesService.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAppServices.id
        virtualNetworkLinkName: virtualNetworkAppServices.name
      }
    ]
  }
  {
    name: 'privatelink.vaultcore.azure.net'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkAppGateway.id
        virtualNetworkLinkName: virtualNetworkAppGateway.name
      }
    ]
  }
  {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkAzureKubernetesService.id
        virtualNetworkLinkName: virtualNetworkAzureKubernetesService.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAppServices.id
        virtualNetworkLinkName: virtualNetworkAppServices.name
      }
    ]
  }
  {
    name: 'privatelink.table.${environment().suffixes.storage}'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.queue.${environment().suffixes.storage}'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.file.${environment().suffixes.storage}'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.web.${environment().suffixes.storage}'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.dfs.${environment().suffixes.storage}'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.2.azurestaticapps.net'
    virtualNetworksLinks: []
  }
  {
    name: 'privatelink.postgres.database.azure.com'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkFlexiblePostgressDatabases.id
        virtualNetworkLinkName: virtualNetworkFlexiblePostgressDatabases.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAzureKubernetesService.id
        virtualNetworkLinkName: virtualNetworkAzureKubernetesService.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAppServices.id
        virtualNetworkLinkName: virtualNetworkAppServices.name
      }
    ]
  }
  {
    name: 'privatelink${environment().suffixes.sqlServerHostname}'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkVirtualMachines.id
        virtualNetworkLinkName: virtualNetworkVirtualMachines.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAzureKubernetesService.id
        virtualNetworkLinkName: virtualNetworkAzureKubernetesService.name
      }
      {
        virtualNetworkLinkId: virtualNetworkAppServices.id
        virtualNetworkLinkName: virtualNetworkAppServices.name
      }
    ]
  }
  {
    name: 'privatelink.northeurope.azmk8s.io'
    virtualNetworksLinks: [
      {
        virtualNetworkLinkId: virtualNetworkAzureKubernetesService.id
        virtualNetworkLinkName: virtualNetworkAzureKubernetesService.name
      }
    ]
  }
]

// Resources
resource virtualNetworkAzureKubernetesService 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}K8sVNet${projectName}${zone}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource virtualNetworkVirtualMachines 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}VirtualMachinesVNet${projectName}${zone}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource virtualNetworkAppServices 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}AppServicesVNet${projectName}${zone}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource virtualNetworkAppGateway 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}AppGatewayVNet${projectName}${zone}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource virtualNetworkStorages 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}StoragesVNet${projectName}${zone}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource virtualNetworkFlexiblePostgressDatabases 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: 'Az${locationShort}FlexiblePostgresDatabasesVNet${projectName}${zone}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

module privateDnsZone '../../modules/coreservices-network/privatednszones.bicep' = [for privateDnsZone in privateDnsZones: {
  name: '${privateDnsZone.name}privatednszone'
  params: {
    privateDnsZone: privateDnsZone
  }
}]

// Outputs
