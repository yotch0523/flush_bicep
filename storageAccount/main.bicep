@description('target region of deploy storage account')
param location string = resourceGroup().location
@description('name of storage account')
param storageAccountName string
@description('boolean whether deploy target storage account')
param isNew bool = false
@allowed([
  'Staging'
  'Production'
])
param env string
@allowed([
  'Standard_ZRS'
  'Standard_LRS'
])
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (false) {
  name: storageAccountName
  location: location
  tags: {
    Environment: env
    Service: 'flush'
  }
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    allowSharedKeyAccess: true
    encryption: {
      requireInfrastructureEncryption: true
      services: {
        file: {
          enabled: true
          keyType: 'Account'
        }
        blob: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

module customRole './customRole.bicep' = {
  name: 'customRoleDeploy'
  params: {
    location: location
    storageAccountName: storageAccountName
    isNew: isNew
  }
}

output storageAccountId string = storageAccount.id
output roleDefinitionId string = customRole.outputs.roleDefinitionId
output uamiId string = customRole.outputs.uamiId
output roleAssignmentId string = customRole.outputs.roleAssignmentId
