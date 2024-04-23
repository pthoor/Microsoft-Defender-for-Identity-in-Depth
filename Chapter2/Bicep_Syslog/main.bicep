targetScope = 'subscription'

// Parameters

param location string

@description('Name of the virtual network, where the load balancer and virtual machines will be created')
param virtualNetworkName string

@description('Name of the subnet in the virtual network where the load balancers will be created. If not specified, will use the same subnet as the virtual machines')
param lbSubnetName string

@description('Name of the subnet within the virtual network where the virtual machines will be connected to')
param vmSubnetName string

@description('The name of the Resource Group containing the Virtual Network')
param virtualNetworkResourceGroup string

@description('Name of the Resource Group where the existing Log Analyics workspace resides')
param workspaceResourceGroup string

@description('Name of the existing Log Analytics workspace with Sentinel')
param workspaceName string

@secure()
param adminPassword string = newGuid()

param environment string

@description('A value to indicate the deployment number.')
@minValue(0)
@maxValue(4)
param sequence int

@minValue(2)
@maxValue(4)
param vmCount int

param os string = 'Ubuntu'
param vmSize string = 'Standard_D2s_v5'
param storageAccountType string
param osDiskSize int
param dataDiskSize int
param adminUserName string
param scriptsLocation string = 'https://raw.githubusercontent.com/SvenAelterman/AzSentinel-syslogfwd-HA/main/scripts/'
param deploymentNamePrefix string

@description('Format string of the resource names.')
param resourceNameFormat string = '{0}-syslog-${environment}-${location}-{1}'

// Variables

param authenticationType string = 'password'

var sequenceFormatted = format('{0:00}', sequence)

var osDetails = {
  Ubuntu: {
    imageReference: {
      publisher: 'canonical'
      offer: '0001-com-ubuntu-server-jammy'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    configScriptName: 'ubuntu.sh'
  }
}

var workspaceId = reference(logAnalytics.id, '2015-11-01-preview').customerId
var workspaceKey = listKeys(logAnalytics.id, '2015-11-01-preview').primarySharedKey

// Resources

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspaceName
  scope: resourceGroup(workspaceResourceGroup)
}

resource target_resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: format(resourceNameFormat, 'rg', sequenceFormatted)
  location: location
}

module loadBalancerInternal './modules/internalloadbalancer.bicep' = if (vmCount > 1) {
  name: '${deploymentNamePrefix}lbi'
  scope: target_resourceGroup
  params: {
    location: location
    subnetName: empty(lbSubnetName) ? vmSubnetName : lbSubnetName
    resourceNameFormat: resourceNameFormat
    sequence: sequence
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
  }
}

module availabilitySet './modules/availabilitySet.bicep' = {
  name: '${deploymentNamePrefix}avail'
  scope: target_resourceGroup
  params: {
    location: location
    resourceNameFormat: resourceNameFormat
    sequence: sequence
  }
}

module vm './modules/vm.bicep' = [for i in range(sequence, vmCount): {
  name: '${deploymentNamePrefix}vm-${i}'
  scope: target_resourceGroup
  params: {
    adminUserName: adminUserName
    osDetail: osDetails[os]
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    subnetName: vmSubnetName
    osDiskSize: osDiskSize
    dataDiskSize: dataDiskSize
    storageAccountType: storageAccountType
    sequence: i
    adminPasswordOrKey: adminPassword
    resourceNameFormat: resourceNameFormat
    location: location
    vmSize: vmSize
    workspaceId: workspaceId
    workspaceKey: workspaceKey
    scriptsLocation: scriptsLocation
    lbiBackendAddressPoolId: vmCount > 1 ? loadBalancerInternal.outputs.backendAddressPoolId : ''
    avsetId: availabilitySet.outputs.avsetId
    authenticationType: authenticationType
  }
}]
