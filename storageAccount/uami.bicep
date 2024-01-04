param location string = resourceGroup().location
param roleDefinitionId string
param storageAccountName string
param isNew bool = false

var managedIdentityName = 'storage-account-uami'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (isNew) {
  name: managedIdentityName
  location: location
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

output storageAccountId string = storageAccount.id

var roleAssignmentId = guid(subscription().id, resourceGroup().id, storageAccountName, managedIdentityName)

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (isNew) {
  name: roleAssignmentId
  scope: storageAccount
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output managedIdentityId string = managedIdentity.id
output roleAssignmentId string = roleAssignment.id
