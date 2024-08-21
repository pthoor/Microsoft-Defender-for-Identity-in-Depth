param dataCollectionEndpointName string

// Deploy a Data Collection Endpoint
resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2022-06-01' = {
  name: dataCollectionEndpointName
  location: resourceGroup().location
  properties: {}
}

output id string = dataCollectionEndpoint.id
