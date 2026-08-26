@allowed([
  'dev'
  'test'
  'prod'
])

@description('This will take environment input from admin and then deploy resource accordingly')
param environmentType string

@description('This define the prefix for naming convention of storageaccount depending on environmentType')
var StorageaccountName = 'st-${environmentType}-${uniqueString(resourceGroup().id)}'

//Below is an example of deploying resource in specific location depending on environment
// param prodLocation string = 'canadacentral'
// param testLocation string = 'eastus'
// param devLocation string = 'westus'
//var locations = environmentType == 'prod' ? prodLocation : environmentType == 'test' ? testLocation : environmentType == 'dev' ? devLocation

@description('This variable defines object properties for each environment')
var Storageenvproperties = {
  prod: {
    choosenlocation: 'eastus'
    skuname: 'Standard_GRS'
    SaccessTier: 'Hot'
  }
  dev: {
    choosenlocation: 'westus'
    skuname: 'Standard_ZRS'
    SaccessTier: 'Cool'
  }
  test: {
    choosenlocation: 'centralus'
    skuname: 'Standard_LRS'
    SaccessTier: 'Cool'
  }
}

@description('This varaible calculates value of above object, so once Bicep evaluates environment value to prod or test or dev, it will become lets say Storagelocations[prod] and once its defined in resource definition, it will resolve to prod.choosenlocation or prod.SaccessTier or prod.skuname')
var Storageproperties = Storageenvproperties[environmentType]

resource storageaccounts 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: StorageaccountName
  location: Storageproperties.choosenlocation
  sku: {
    name: Storageproperties.skuname
  }
  kind: 'StorageV2'
  properties: {
    accessTier: Storageproperties.SaccessTier
  }
}

resource storageblobservice 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  name: 'default'
  parent: storageaccounts
}

resource Storageblobcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
  name: 'Files-${environmentType}'
  parent: storageblobservice
}
