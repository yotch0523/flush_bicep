param location string = resourceGroup().location
param storageAccountName string
param isNew bool = false

@description('custom role enables principal to read/write/delete storage account（Azure RBAC）')
var actions = [
  'Microsoft.Storage/storageAccounts/blobServices/containers/*'
  'Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey'
]
var dataActions = [
  'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/*'
]

var roleDefinitionName = 'Storage Account Custom role for app'
var roleDefinitionId = guid(subscription().id, 'role-for-app-storage-account-definition')

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = if (isNew) {
  name: roleDefinitionId
  properties: {
    roleName: roleDefinitionName
    description: 'custom role enables app to read/write blob in storage account'
    type: 'customRole'
    permissions: [
      {
        actions: actions
        dataActions: dataActions
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

module uami './uami.bicep' = {
  name: 'storageAccountUamiDeploy'
  params: {
    location: location
    roleDefinitionId: roleDefinitionId
    storageAccountName: storageAccountName
    isNew: isNew
  }
}

output roleDefinitionId string = roleDefinition.id
output uamiId string = uami.outputs.managedIdentityId
output roleAssignmentId string = uami.outputs.roleAssignmentId
