@description('region of target resource group')
param location string = resourceGroup().location
@description('Name of CosmosDB account（max char length: 44）')
param accountName string
@description('Service principal id of role assignment target(guid)')
param principalId string
@description('object id of user principal(guid)')
param administratorPrincipalId string

param isNew bool = false

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = if (isNew) {
  name: accountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    enableFreeTier: true
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
  }
}

module customRole './customRole.bicep' = {
  name: 'customRoleDeploy'
  params : {
    principalId: administratorPrincipalId
  }
}
module servicePrincipalCustomRole './servicePrincipalCustomRole.bicep' = {
  name: 'servicePrincipalCustomRoleDeploy'
  params: {
    accountName: accountName
    principalId: principalId
  }
}
