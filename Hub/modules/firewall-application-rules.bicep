targetScope = 'resourceGroup'

// Parameters

// @allowed([
//   'We'
// ])
// param locationShort string

param firewallPolicyName string

// Existing Resources

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-05-01' existing = {
  name: firewallPolicyName
}

// resource ipGroupMario 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGMario'
// }
// resource ipGroupIvan 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGIvan'
// }
// resource ipGroupGunter 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGGunter'
// }
// resource ipGroupBastion 'Microsoft.Network/ipGroups@2021-05-01' existing = {
//   name: 'Az${locationShort}IPGBastion'
// }

//L7 Application rules
resource applicactionFirewallPolicyRules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-05-01' = {
  name: 'ApplicationRuleCollectionGroup'
  parent: firewallPolicy
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'App-rules'
        priority: 101
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          // {
          //   name: 'Allow-AKS-Nodes-443'
          //   description: 'Allow main Kubernetes tools providers'
          //   sourceIpGroups: [
          //     ipGroupAzureKubernetesServiceDealerHUB.id
          //     ipGroupAzureKubernetesServiceIoTHUB.id
          //   ]
          //   terminateTLS: false
          //   ruleType: 'ApplicationRule'
          //   destinationAddresses: [ 'FQDN' ]
          //   targetFqdns: [
          //     '*.azmk8s.io'
          //     '*.k8s.io'
          //     '*.cloud.google.com'
          //     '*.kubernetes.io'
          //     '*.googleapis.com'
          //     '*.helm.sh'
          //     'baltocdn.com'
          //     '*.pkg.dev'
          //     '*.docker.io'
          //     '*.docker.com'
          //     'github.com'
          //     'raw.githubusercontent.com'
          //     '*.amazonaws.com'
          //     '*.snapcraft.io'
          //     '*.ubuntu.com'
          //     '*.sap.com'
          //     '*.dynatrace.com'
          //     '*.northeurope.azure.elastic-cloud.com'
          //     '*.dealerhub.com'
          //     '*.azurestaticapps.net' // Web Apps
          //     'packages.microsoft.com'
          //     '*.microsoft.com'
          //     '*.azure-api.net' //API Management
          //     '*.openpolicyagent.org' //OPAL
          //     '*.commerce.ondemand.com' //SAP CDC
          //     '*.eu1.gigya.com' //SAP CDC
          //     '*.informaticacloud.com' //Informatica cloud
          //     '*.windows.net'
          //     'aka.ms'
          //     'download.opensuse.com'
          //     'download.opensuse.org'
          //     'ftp.gwdg.de'
          //     '*.api.letsencrypt.org'
          //     'ghcr.io'
          //     '*.azureedge.net'
          //     '*.cdn.snapcraftcontent.com'
          //     'aadcdn.msftauth.net'
          //     'azure.github.io'
          //     'charts.jetstack.io'
          //     'kedacore.github.io'
          //     'permitio.github.io'
          //     '*selenium.dev'
          //     'kubernetes.github.io'
          //     'objects.githubusercontent.com'
          //     'oauth2-proxy.github.io'
          //     '*quay.io'
          //     '*.elastic.co'
          //     'd2iks1dkcwqcbx.cloudfront.net' // CNAME docker.elastic.co
          //     dealerNetUrl[zone]
          //     'api.github.com'
          //     'pact-foundation.github.io'
          //     'int.lightspeeddataservices.com' //Lightspeed PoC
          //     'lightspeeddataservices.com' //Lightspeed PoC
          //     'cdkglobal.bravais.com' //Lightspeed PoC
          //     'codecentric.github.io'
          //     'sonarcloud.io'
          //     'scanner.sonarcloud.io'
          //     '*.dev.azure.com'
          //     'pkg-containers.githubusercontent.com'
          //     'nodejs.org'
          //     'registry.npmjs.org'
          //     'dl-cdn.alpinelinux.org'
          //     'deb.debian.org'
          //     '*.sibros.tech'
          //     'ktm-testv16.braintec.cloud'
          //     'api.nuget.org'
          //   ]
          //   protocols: [
          //     {
          //       port: 443
          //       protocolType: 'Https'
          //     }
          //   ]
          // }
        ]
      }
    ]
  }
}
