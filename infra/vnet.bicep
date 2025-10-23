@description('Name of the storage account')
param storageAccountName string

@description('Location for the storage account')
param location string = resourceGroup().location

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
])
param sku string = 'Standard_LRS'
param doesSupportHttpsTrafficOnly bool = true

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: doesSupportHttpsTrafficOnly
  }
}

output storageAccountId string = storageAccount.id
