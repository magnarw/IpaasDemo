@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location


@description('The language worker runtime to load in the function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param runtime string = 'dotnet'
param serviceBusNamespaceName string
param queueName string
param storageAccountName string
param applicationInsightsName string
param functionAppName string
param hostingPlanName string
var functionWorkerRuntime = runtime

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: serviceBusNamespaceName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  tags: {
    displayName: 'ServiceBusNamespace'
  }
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
  parent: serviceBusNamespace
  name: queueName
  properties: {
    lockDuration: 'PT1M'
    maxDeliveryCount: 10
    enablePartitioning: false
  }
}



resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'SERVICEBUS_ENDPOINT'
          value: serviceBusNamespace.properties.serviceBusEndpoint
        }
        {
          name: 'PO_QUEUE_NAME'
          value: queue.name
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}


resource roleAssignmentSender 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(uniqueString('serviceBusDataSender'))
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/69a216fc-b8fb-44d8-bc22-1f3c2cd27a39' // Azure Service Bus Data Sender role definition ID
    scope:  resourceGroup().id
  }
}

resource roleAssignmentReceiver 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(uniqueString('serviceBusDataReceiver'))
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0' // Azure Service Bus Data Receiver role definition ID
    scope: resourceGroup().id
  }
}


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
