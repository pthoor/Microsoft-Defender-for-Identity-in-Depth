param location string

@description('A value to indicate the deployment number.')
@minValue(0)
@maxValue(99)
param sequence int = 1

@description('Format string of the resource names.')
param resourceNameFormat string = '{0}-syslog-{1}'

var sequenceFormatted = format('{0:00}', sequence)

resource ppg 'Microsoft.Compute/proximityPlacementGroups@2021-04-01' = {
  name: format(resourceNameFormat, 'ppg', sequenceFormatted)
  location: location
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

resource avset 'Microsoft.Compute/availabilitySets@2021-04-01' = {
  name: format(resourceNameFormat, 'avail', sequenceFormatted)
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 3
    platformUpdateDomainCount: 2
    proximityPlacementGroup: {
      id: ppg.id
    }
  }
}

output avsetId string = avset.id
