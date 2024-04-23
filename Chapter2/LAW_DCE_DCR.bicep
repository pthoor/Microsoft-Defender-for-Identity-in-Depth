// Define parameters
param location string = 'swedencentral' // You can change the location accordingly
param workspaceName string = 'myLogAnalyticsWorkspace'
param dataCollectionEndpointPrefix string = 'dce'
param dataCollectionEndpointName string = '${dataCollectionEndpointPrefix}-${location}'
param dataCollectionRulePrefix string = 'dcr'
param dataCollectionRuleSuffix string = 'mdi-config-monitoring'
param dataCollectionRuleName string = '${dataCollectionRulePrefix}-${dataCollectionRuleSuffix}'

@description('The names of the virtual machines.')
param vmNames array

@description('The name of the association.')
param associationName string

// Deploy a Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Deploy a Data Collection Endpoint
resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2022-06-01' = {
  name: dataCollectionEndpointName
  location: location
  properties: {}
}

// Deploy a Data Collection Rule
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: dataCollectionRuleName
  location: location
  properties: {
    destinations: {
      logAnalytics: [
        {
          resourceId: logAnalyticsWorkspace.id
        }
      ]
    }
    dataSources: {
      performanceCounters: []
      windowsEventLogs: []
    }
    dataFlows: []
  }
}

output dataCollectionRuleId string = dataCollectionRule.id

resource vm 'Microsoft.HybridCompute/machines@2022-12-27' existing = [for vmName in vmNames: {
  name: vmName
}]

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = [for vmName in vmNames: {
  name: '${associationName}-${vmName}'
  scope: vmName
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this Arc server.'
    dataCollectionRuleId: dataCollectionRuleId
  }
}]
