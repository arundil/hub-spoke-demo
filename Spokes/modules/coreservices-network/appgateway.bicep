targetScope = 'resourceGroup'

// Parameters
param projectName string
param location string = resourceGroup().location

@allowed([
  'We'
])
param locationShort string

@allowed([
  'DEV'
  'TEST'
  'STAGE'
  'PROD'
])
param zone string

// Local parameters
param appGatewaySubnetId string

param IPOAuth2Proxy string
param IPLogin string
param IPBffGateway string
param IPAttachment string
param IPVehicle string
param IPVehicleInspection string
param IPUserAccessControl string
param IPSparePartsFinder string
param IPModelStructure string
param IPPrice string
param IPMasterData string
param IPKibana string
param IPSpecialItemValidation string
param IPCart string
param IPDownloadCenter string

// Variables
var frontendResourceGroup = 'RG_${zone}_CoreServices_Frontend'
var coreResourceGroup = 'RG_${zone}_CoreServices'
var identityResourceGroup = 'RG_${zone}_ManagedIdentities'

var applicationGatewayWAFPolicyName = 'Az${locationShort}WAFAPPGW${zone}'
var applicationGatewayPublicIPName = (zone != 'DEV') ? 'Az${locationShort}IPFrontendAPPGW${zone}' : 'Az${locationShort}IPFrontendAPPGW'
var applicationGatewayName = 'Az${locationShort}APPGateway${zone}'
var applicationGatewayManagedIDName = 'Az${locationShort}UAIAppGateway${zone}'

var certificateSecretName = 'wildcard-${toLower(zone)}-dealerhub-com'
var applicationGatewayCertName = 'KeyVault_${certificateSecretName}'

var applicationGatewayCertId = resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, applicationGatewayCertName)

var projectZoneDomain = (zone != 'PROD') ? '${toLower(zone)}.${toLower(projectName)}' : '${toLower(projectName)}'

var urlOAuth2Proxy = '${projectZoneDomain}.com'
var urlLogin = 'login.${projectZoneDomain}.com'
var urlBffGateway = 'bff.${projectZoneDomain}.com'
var urlAttachment = 'attachment.${projectZoneDomain}.com'
var urlVehicle = 'vehicle.${projectZoneDomain}.com'
var urlVehicleInspection = 'vehicleinspection.${projectZoneDomain}.com'
var urlUserAccessControl = 'useraccesscontrol.${projectZoneDomain}.com'
var urlSparePartsFinder = 'sparepartsfinder.${projectZoneDomain}.com'
var urlModelStructure = 'modelstructure.${projectZoneDomain}.com'
var urlPrice = 'price.${projectZoneDomain}.com'
var urlMasterData = 'masterdata.${projectZoneDomain}.com'
var urlKibana = 'kibana.${projectZoneDomain}.com'
var urlSpecialItemValidation = 'specialitemvalidation.${projectZoneDomain}.com'
var urlCart = 'cart.${projectZoneDomain}.com'
var urlDownloadCenter = 'downloadcenter.${projectZoneDomain}.com'

var zoneShort = {
  DEV: 'DEV'
  TEST: 'TEST'
  STAGE: 'STG'
  PROD: 'PROD'
}

// Resources
resource certificateSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' existing = {
  scope: resourceGroup(coreResourceGroup)
  name: 'Az${locationShort}KVCoreServicesDH${zoneShort[zone]}/${certificateSecretName}'
}

resource apiManagementService 'Microsoft.ApiManagement/service@2021-04-01-preview' existing = {
  scope: resourceGroup(frontendResourceGroup)
  name: 'Az${locationShort}APIGW${projectName}${zone}'
}

resource applicationGatewayManagedID 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(identityResourceGroup)
  name: applicationGatewayManagedIDName
}

resource applicationGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: applicationGatewayPublicIPName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGatewayWAFPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-05-01' = {
  name: applicationGatewayWAFPolicyName
  location: location
  properties: {
    customRules: [
      {
        name: 'AllowApiGatewayIP'
        priority: 30
        ruleType: 'MatchRule'
        action: 'Allow'
        // rateLimitThreshold: 0
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: false
            matchValues: apiManagementService.properties.publicIPAddresses
            transforms: []
          }
        ]
      }
      {
        name: 'AllowGraphQLSubscription'
        priority: 40
        ruleType: 'MatchRule'
        action: 'Allow'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestMethod'
              }
            ]
            operator: 'Equal'
            negationConditon: false
            matchValues: [
              'GET'
              'POST'
            ]
          }
          {
            matchVariables: [
              {
                variableName: 'RequestUri'
              }
            ]
            operator: 'Equal'
            negationConditon: false
            matchValues: [
              '/graphql'
              '/graphqlws'
            ]
            transforms: [
              'Lowercase'
            ]
          }
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'Sec-WebSocket-Protocol'
              }
            ]
            operator: 'Equal'
            negationConditon: false
            matchValues: [
              'graphql-transport-ws'
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
      {
        name: 'DefaultDenyAll'
        priority: 100
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: false
            matchValues: [
              '0.0.0.0/1'
              '128.0.0.0/2'
              '192.0.0.0/3'
              '224.0.0.0/4'
            ]
            transforms: []
          }
        ]
      }
      {
        name: 'KeycloakAccess'
        priority: 35
        ruleType: 'MatchRule'
        action: 'Allow'
        matchConditions: [
          {
            matchVariables: [
              {
                selector: 'Host'
                variableName: 'RequestHeaders'
              }
            ]
            operator: 'Equal'
            negationConditon: false
            matchValues: [
              urlLogin
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
      {
        name: 'KibanaAccess'
        priority: 37
        ruleType: 'MatchRule'
        action: 'Allow'
        matchConditions: [
          {
            matchVariables: [
              {
                selector: 'Host'
                variableName: 'RequestHeaders'
              }
            ]
            operator: 'Equal'
            negationConditon: false
            matchValues: [
              urlKibana
              'www.${urlKibana}'
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
      {
        name: 'OAuth2ProxyAccess'
        priority: 36
        ruleType: 'MatchRule'
        action: 'Allow'
        matchConditions: [
          {
            matchVariables: [
              {
                selector: 'Host'
                variableName: 'RequestHeaders'
              }
            ]
            operator: 'Equal'
            negationConditon: false
            matchValues: [
              urlOAuth2Proxy
              'www.${urlOAuth2Proxy}'
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: false
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-932-APPLICATION-ATTACK-RCE'
              rules: [
                {
                  ruleId: '932110'
                  state: 'Disabled'
                }
                {
                  ruleId: '932115'
                  state: 'Disabled'
                }
                {
                  ruleId: '932100'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
                {
                  ruleId: '920350'
                  state: 'Disabled'
                }
              ]
            }
            {
              ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
              rules: [
                {
                  ruleId: '942432'
                  state: 'Disabled'
                }
                {
                  ruleId: '942431'
                  state: 'Disabled'
                }
                {
                  ruleId: '942430'
                  state: 'Disabled'
                }
                {
                  ruleId: '942421'
                  state: 'Disabled'
                }
                {
                  ruleId: '942420'
                  state: 'Disabled'
                }
              ]
            }
          ]
        }
      ]
      exclusions: [
        {
          matchVariable: 'RequestCookieNames'
          selectorMatchOperator: 'Equals'
          selector: '_oauth2_proxy_0'
          exclusionManagedRuleSets: []
        }
        {
          matchVariable: 'RequestCookieNames'
          selectorMatchOperator: 'Equals'
          selector: '_oauth2_proxy_1'
          exclusionManagedRuleSets: []
        }
      ]
    }
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${applicationGatewayManagedID.id}': {}
    }
  }
  properties: {
    sslCertificates: [
      {
        name: applicationGatewayCertName
        properties: {
          keyVaultSecretId: certificateSecret.properties.secretUri
        }
      }
    ]
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appGatewaySubnetId
          }
        }
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: applicationGatewayPublicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_81'
        properties: {
          port: 81
        }
      }
      {
        name: 'port_84'
        properties: {
          port: 84
        }
      }
      {
        name: 'port_85'
        properties: {
          port: 85
        }
      }
      {
        name: 'port_87'
        properties: {
          port: 87
        }
      }
      {
        name: 'port_88'
        properties: {
          port: 88
        }
      }
      {
        name: 'port_89'
        properties: {
          port: 89
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'OAuth2ProxyBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: IPOAuth2Proxy
            }
          ]
        }
      }
      {
        name: 'LoginBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPLogin
            }
          ]
        }
      }
      {
        name: 'BFFGatewayBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: IPBffGateway
            }
          ]
        }
      }
      {
        name: 'AttachmentBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: IPAttachment
            }
          ]
        }
      }
      {
        name: 'VehicleInspectionBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: IPVehicleInspection
            }
          ]
        }
      }
      {
        name: 'VehicleBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: IPVehicle
            }
          ]
        }
      }
      {
        name: 'UserAccessControlBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPUserAccessControl
            }
          ]
        }
      }
      {
        name: 'SparePartsFinderBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPSparePartsFinder
            }
          ]
        }
      }
      {
        name: 'ModelStructureBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPModelStructure
            }
          ]
        }
      }
      
      {
        name: 'MasterDataBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPMasterData
            }
          ]
        }
      }
      {
        name: 'PriceBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPPrice
            }
          ]
        }
      }
      {
        name: 'KibanaBackendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: IPKibana
            }
          ]
        }
      }
      {
        name: 'SpecialItemValidationBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPSpecialItemValidation
            }
          ]
        }
      }
      {
        name: 'CartBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPCart
            }
          ]
        }
      }
      {
        name: 'DownloadCenterBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: IPDownloadCenter
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'OAuth2ProxyHttpConfig'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'OAuthProxyHealthProbe')
          }
        }
      }
      {
        name: 'LoginHttpConfig'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          hostName: urlLogin
          pickHostNameFromBackendAddress: false
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'KeycloakHealthProbe')
          }
        }
      }
      {
        name: 'BFFGatewayHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'AttachmentHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'VehicleInspectionHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'VehicleHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'UserAccessControlHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'SparePartsFinderHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'ModelStructureHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'MasterDataHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'PriceHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'KibanaHttpConfig'
        properties: {
          port: 5601
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'KibanaHealthProbe')
          }
        }
      }
      {
        name: 'SpecialItemValidationHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'CartHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
      {
        name: 'DownloadCenterHttpConfig'
        properties: {
          port: 8080
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'ServiceHealthProbe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'OAuth2ProxyListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [
            urlOAuth2Proxy
            'www.${urlOAuth2Proxy}'
          ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'LoginListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlLogin ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'BFFGatewayListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlBffGateway ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'AttachmentListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_81')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlAttachment ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'VehicleListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlVehicle ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'VehicleInspectionListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlVehicleInspection ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'UserAccessControlListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_85')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlUserAccessControl ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'WebsocketListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_88')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          requireServerNameIndication: false
        }
      }
      {
        name: 'SparePartsFinderListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlSparePartsFinder ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'ModelStructureListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlModelStructure ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'MasterDataListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlMasterData ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'PriceListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_87')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlPrice ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'KibanaListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [
            urlKibana
            'www.${urlKibana}'
          ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'SpecialItemValidationListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_89')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlSpecialItemValidation ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'CartListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlCart ]
          requireServerNameIndication: true
        }
      }
      {
        name: 'DownloadCenterListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: applicationGatewayCertId
          }
          hostNames: [ urlDownloadCenter ]
          requireServerNameIndication: true
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'OAuth2ProxyRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10010
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'OAuth2ProxyListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'OAuth2ProxyBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'OAuth2ProxyHttpConfig')
          }
        }
      }
      {
        name: 'LoginRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10020
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'LoginListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'LoginBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'LoginHttpConfig')
          }
        }
      }
      {
        name: 'BFFGatewayRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10030
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'BFFGatewayListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'BFFGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'BFFGatewayHttpConfig')
          }
        }
      }
      {
        name: 'WebsocketRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10210
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'WebsocketListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'BFFGatewayBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'BFFGatewayHttpConfig')
          }
          rewriteRuleSet: {
            id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', applicationGatewayName, 'rewriteGraphqlSubscription')
          }
        }
      }
      {
        name: 'AttachmentRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10040
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'AttachmentListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'AttachmentBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'AttachmentHttpConfig')
          }
        }
      }
      {
        name: 'VehicleInspectionRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10050
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'VehicleInspectionListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'VehicleInspectionBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'VehicleInspectionHttpConfig')
          }
        }
      }
      {
        name: 'UserAccessControlRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10060
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'UserAccessControlListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'UserAccessControlBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'UserAccessControlHttpConfig')
          }
        }
      }
      {
        name: 'SparePartsFinderRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10070
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'SparePartsFinderListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'SparePartsFinderBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'SparePartsFinderHttpConfig')
          }
        }
      }
      {
        name: 'ModelStructureRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10080
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'ModelStructureListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'ModelStructureBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'ModelStructureHttpConfig')
          }
        }
      }
      {
        name: 'MasterDataRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10111
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'MasterDataListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'MasterDataBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'MasterDataHttpConfig')
          }
        }
      }
      {
        name: 'PriceRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10090
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'PriceListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'PriceBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'PriceHttpConfig')
          }
        }
      }
      {
        name: 'KibanaRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10110
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'KibanaListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'KibanaBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'KibanaHttpConfig')
          }
        }
      }
      {
        name: 'SpecialItemValidationRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10120
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'SpecialItemValidationListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'SpecialItemValidationBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'SpecialItemValidationHttpConfig')
          }
        }
      }
      {
        name: 'CartRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10130
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'CartListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'CartBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'CartHttpConfig')
          }
        }
      }
      {
        name: 'VehicleRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10140
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'VehicleListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'VehicleBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'VehicleHttpConfig')
          }
        }
      }
         {
        name: 'DownloadCenterRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10150
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'DownloadCenterListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'DownloadCenterBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'DownloadCenterHttpConfig')
          }
        }
      }
    ]
    probes: [
      {
        name: 'ServiceHealthProbe'
        properties: {
          protocol: 'Http'
          path: '/health'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            body: 'Healthy'
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'KeycloakHealthProbe'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            body: ''
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'OAuthProxyHealthProbe'
        properties: {
          protocol: 'Http'
          path: '/ping'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            body: ''
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'KibanaHealthProbe'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            body: ''
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'rewriteGraphqlSubscription'
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              conditions: [
                {
                  variable: 'var_uri_path'
                  pattern: '/graphqlws'
                  ignoreCase: true
                  negate: false
                }
              ]
              name: 'graphqlws'
              actionSet: {
                requestHeaderConfigurations: []
                responseHeaderConfigurations: []
                urlConfiguration: {
                  modifiedPath: '/graphql'
                  reroute: false
                }
              }
            }
          ]
        }
      } ]
    redirectConfigurations: []
    privateLinkConfigurations: []
    sslPolicy: {
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: [
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256'
      ]
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
      disabledRuleGroups: []
      exclusions: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: true
    forceFirewallPolicyAssociation: true
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 10
    }
    customErrorConfigurations: []
    firewallPolicy: {
      id: applicationGatewayWAFPolicy.id
    }
  }
}

// Outputs
output applicationGatewayIP string = applicationGatewayPublicIP.properties.ipAddress
