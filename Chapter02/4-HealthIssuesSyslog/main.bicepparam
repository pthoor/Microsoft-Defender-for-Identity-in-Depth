using './main.bicep'

param location = 'westeurope'
param vmName = 'syslog'
param dcrName = 'p-syslog-dcr'
param virtualNetworkName = 'contoso1-vnet'
param lbSubnetName = 'srvSubnet1'
param vmSubnetName = 'srvSubnet1'
param virtualNetworkResourceGroup = 'ArcLabTest'
param workspaceResourceGroup = 'rg-sentinel'
param workspaceName = 'ThoorSentinel-v2'
param environment = 'prod'
param SyslogSrvToDeploy = 2
param os = 'Ubuntu'
param vmSize = 'Standard_D2s_v5'
param storageAccountType = 'Standard_LRS'
param osDiskSize = 30
param dataDiskSize = 32
param adminUserName = 'azureuser'
param deploymentNamePrefix = 'syslog-HA-'
param authenticationType = 'password'
