using './main.bicep'

param location = 'westeurope'
param virtualNetworkName = 'contoso1-vnet'
param lbSubnetName = 'srvSubnet1'
param vmSubnetName = 'srvSubnet1'
param virtualNetworkResourceGroup = 'ArcLabTest'
param workspaceResourceGroup = 'rg-sentinel'
param workspaceName = 'ThoorSentinel-v2'
param environment = 'prod'
param sequence = 1
param vmCount = 2
param os = 'Ubuntu'
param vmSize = 'Standard_D2s_v5'
param storageAccountType = 'Standard_LRS'
param osDiskSize = 30
param dataDiskSize = 64
param adminUserName = 'azureuser'
param scriptsLocation = 'https://raw.githubusercontent.com/SvenAelterman/AzSentinel-syslogfwd-HA/main/scripts/'
param deploymentNamePrefix = 'syslog-HA-'
param resourceNameFormat = '{0}-syslog-${environment}-${location}-{1}'
param authenticationType = 'password'

