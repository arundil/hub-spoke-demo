targetScope = 'resourceGroup'

// Parameters
param dnsZoneName string
param dnsRecords array

// Resources
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: 'global'
}

resource dnsZoneCnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = [for dnsRecord in dnsRecords: if (dnsRecord.type == 'CNAME') {
  parent: dnsZone
  name: dnsRecord.name
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: dnsRecord.cname
    }
  }
}]

resource dnsZoneARecord 'Microsoft.Network/dnsZones/A@2018-05-01' = [for dnsRecord in dnsRecords: if (dnsRecord.type == 'A') {
  parent: dnsZone
  name: dnsRecord.name
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: dnsRecord.ipv4Address
      }
    ]
  }
}]

resource dnsZoneNSRecord 'Microsoft.Network/dnsZones/NS@2018-05-01' = [for dnsRecord in dnsRecords: if (dnsRecord.type == 'NS') {
  parent: dnsZone
  name: dnsRecord.name
  properties: {
    TTL: 3600
    NSRecords: dnsRecord.nsdNames
  }
}]

resource dnsZoneTXTRecord 'Microsoft.Network/dnszones/TXT@2018-05-01' = [for dnsRecord in dnsRecords: if (dnsRecord.type == 'TXT') {
  parent: dnsZone
  name: dnsRecord.name
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [
          dnsRecord.value
        ]
      }
    ]
  }
}]

output nameServers array = dnsZone.properties.nameServers
