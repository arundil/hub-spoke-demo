targetScope = 'resourceGroup'

// Parameters
param location string = resourceGroup().location
param locationShort string

@description('The gallery that the workbook will been shown under.')
param workbookType string = 'workbook'

@description('The id of resource instance to which the workbook will be associated')
param workbookSourceId string

@description('Content of worbook Charts')
param workbookCharts string

@description('Purpose name of workbook.')
param workbookPurposeName string

// Variables
var workbookName = 'Az${locationShort}${workbookPurposeName}'

// Resources
resource workbook 'microsoft.insights/workbooks@2022-04-01' = {
  name: guid(workbookName)
  location: location
  kind: 'shared'
  properties: {
    displayName: workbookName
    serializedData: workbookCharts
    version: '1.0'
    sourceId: workbookSourceId
    category: workbookType
  }
}

output workbookId string = workbook.id
