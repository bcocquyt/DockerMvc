# Build and depoy an AspDotNet application to a docker container on Azure

Create DotNet MVC Project
```
dotnet new mvc -o docker_mvc
```
Output:
```
Getting ready...
The template "ASP.NET Core Web App (Model-View-Controller)" was created successfully.
This template contains technologies from parties other than Microsoft, see https://aka.ms/aspnetcore/3.1-third-party-notices for details.

Processing post-creation actions...
Running 'dotnet restore' on docker_mvc\docker_mvc.csproj...
  Restore completed in 373.35 ms for C:\users\xxx\Source\repos\docker_mvc\docker_mvc.csproj.

Restore succeeded.
```

Build and Run Project
```
cd docker_mvc
dotnet run
```
Output:
```
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: https://localhost:5001
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Development
info: Microsoft.Hosting.Lifetime[0]
      Content root path: C:\users\xxx\Source\repos\docker_mvc
```

Terminate the application by pressing CTRL+C.

Package Project for Deployment
```
dotnet publish -c release -o app/ .
```

Output:
```
Microsoft (R) Build Engine version 16.5.0+d4cbfca49 for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 40.09 ms for C:\users\bcocquyt\Source\repos\docker_mvc\docker_mvc.csproj.
  docker_mvc -> C:\users\bcocquyt\Source\repos\docker_mvc\bin\release\netcoreapp3.1\docker_mvc.dll
  docker_mvc -> C:\users\bcocquyt\Source\repos\docker_mvc\bin\release\netcoreapp3.1\docker_mvc.Views.dll
  docker_mvc -> C:\users\bcocquyt\Source\repos\docker_mvc\app\
```

Create file with name dockerfile with folowing conent:
```
FROM microsoft/dotnet:3.1-aspnetcore-runtime
WORKDIR /app
COPY /app /app
ENTRYPOINT ["dotnet" , "docker_mvc.dll"]
```

(optional) Create file with name dockerfile with folowing conent:
```
bin\
obj\
```

Build container
```
docker build -t <docker-container-name> .
```

Output:
```
Sending build context to Docker daemon  12.39MB
Step 1/4 : FROM mcr.microsoft.com/dotnet/core/runtime:3.1
3.1: Pulling from dotnet/core/runtime
afb6ec6fdc1c: Pull complete
5690d8bb6f50: Pull complete
63fdd22196ea: Pull complete
e0a4da67bf1b: Pull complete
Digest: sha256:3a4e95eb1ed2255012bb160d099fc40e297f4feeffab471e3c53c0a786a8dbf7
Status: Downloaded newer image for mcr.microsoft.com/dotnet/core/runtime:3.1
 ---> 79a3edafca89
Step 2/4 : WORKDIR /app
 ---> Running in d0f5d07d2658
Removing intermediate container d0f5d07d2658
 ---> d0bdefd8b4b5
Step 3/4 : COPY /app /app
 ---> 641afa973846
Step 4/4 : ENTRYPOINT ["dotnet" , "docker_mvc.dll"]
 ---> Running in 85f7b2ae287c
Removing intermediate container 85f7b2ae287c
 ---> cc88a61bec9a
Successfully built cc88a61bec9a
Successfully tagged <docker-container-name>:latest
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.
```

Run App in container
```
docker run -p 8181:80 docker_mvc
```

Output:
```
warn: Microsoft.AspNetCore.DataProtection.Repositories.FileSystemXmlRepository[60]
      Storing keys in a directory '/root/.aspnet/DataProtection-Keys' that may not be persisted outside of the container. Protected data will be unavailable when container is destroyed.
warn: Microsoft.AspNetCore.DataProtection.KeyManagement.XmlKeyManager[35]
      No XML encryptor configured. Key {eba0a1e9-ae5f-44ea-9733-22c23c4c94df} may be persisted to storage in unencrypted form.
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /app
warn: Microsoft.AspNetCore.HttpsPolicy.HttpsRedirectionMiddleware[3]
      Failed to determine the https port for redirect.
```

Log in into Azure
```
az login
```

Output:
```
Note, we have launched a browser for you to login. For old experience with device code, use "az login --use-device-code"
You have logged in. Now let us find all the subscriptions to which you have access...
[
  {
    "cloudName": "XxxxxXxxxx",
    "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "isDefault": true,
    "name": "Xxxx Xxxx Xxxxxxxx",
    "state": "Enabled",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
    "user": {
      "name": "xxxxx@xxxx.xxx",
      "type": "user"
    }
  }
]
```


Create Resource Group in Azure
```
az group create --name <resource-group-name> --location westeurope
```

Output:
```
{
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<resource-group-name>",
  "location": "xxxxxxxxx",
  "managedBy": null,
  "name": "<resource-group-name>",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null
}
```

Create Container Registry
```
az acr create -g <resource-group-name> --name <container-registry-name> --sku Basic --admin-enabled true
```

Output:
```
{
  "adminUserEnabled": true,
  "creationDate": "2020-05-22T14:45:15.018913+00:00",
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<resource-group-name>/providers/Microsoft.ContainerRegistry/registries/<container-registry-name>",
  "location": "westeurope",
  "loginServer": "<container-registry-name>.azurecr.io",
  "name": "<container-registry-name>",
  "provisioningState": "Succeeded",
  "resourceGroup": "<resource-group-name>",
  "sku": {
    "name": "Basic",
    "tier": "Basic"
  },
  "status": null,
  "storageAccount": null,
  "tags": {},
  "type": "Microsoft.ContainerRegistry/registries"
}
```

Retrieve credentials
```
az acr credential show -n <container-registry-name>
```

Output:
```
{
  "passwords": [
    {
      "name": "password",
      "value": "<by-azure-generated-password-1>"
    },
    {
      "name": "password2",
      "value": "<by-azure-generated-password-2>"
    }
  ],
  "username": "<container-registry-name>"
}
```

Tag Container
```
docker tag <docker-container-name> <container-registry-name>.azurecr.io/<docker-container-name>:v1
```

No output

Login Container Registry
```
docker login https://<container-registry-name>.azurecr.io -u <container-registry-name> -p <by-azure-generated-password-1>
```

Output
```
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
Login Succeeded
```

Push Image to Registry
```
docker push <container-registry-name>.azurecr.io/<docker-container-name>:v1
```

Create Consumption Plan for WebApp
```
az appservice plan create -n <consumption-plan-name> -g <resource-group-name> --sku S1 --is-linux
```

Output:
```
```

Create WebApp
Not all runtimes seem to work, this one works for me. The value is not really important as we are going to use our own docker container. I tried some values from the list returned by: az webapp list-runtimes, but some of them work, and some don't. Don't ask me why...
```
az webapp create -g <resource-group-name> -p <consumption-plan-name> -n <azure-webapp-name> --% --runtime "node|8.1"
```

Output:
```
...
{
  "availabilityState": "Normal",
  "clientAffinityEnabled": true,
  "clientCertEnabled": false,
  "cloningInfo": null,
  "containerSize": 0,
  "dailyMemoryTimeQuota": 0,
  "defaultHostName": "<azure-webapp-name>.azurewebsites.net",
  "enabled": true,
  "enabledHostNames": [
    "<azure-webapp-name>.azurewebsites.net",
    "<azure-webapp-name>.scm.azurewebsites.net"
  ],
  "ftpPublishingUrl": "ftp://waws-prod-am2-311.ftp.azurewebsites.windows.net/site/wwwroot",
  "hostNameSslStates": [
    {
      "hostType": "Standard",
      "ipBasedSslResult": null,
      "ipBasedSslState": "NotConfigured",
      "name": "<azure-webapp-name>.azurewebsites.net",
      "sslState": "Disabled",
      "thumbprint": null,
      "toUpdate": null,
      "toUpdateIpBasedSsl": null,
      "virtualIp": null
    },
    {
      "hostType": "Repository",
      "ipBasedSslResult": null,
      "ipBasedSslState": "NotConfigured",
      "name": "<azure-webapp-name>.scm.azurewebsites.net",
      "sslState": "Disabled",
      "thumbprint": null,
      "toUpdate": null,
      "toUpdateIpBasedSsl": null,
      "virtualIp": null
    }
  ],
  "hostNames": [
    "<azure-webapp-name>.azurewebsites.net"
  ],
  "hostNamesDisabled": false,
  "hostingEnvironmentProfile": null,
  "httpsOnly": false,
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<resource-group-name>/providers/Microsoft.Web/sites/<azure-webapp-name>",
  "identity": null,
  "isDefaultContainer": null,
  "kind": "app,linux",
  "lastModifiedTimeUtc": "2020-05-22T15:47:30.093333",
  "location": "West Europe",
  "maxNumberOfWorkers": null,
  "name": "<azure-webapp-name>",
  "outboundIpAddresses": "13.69.68.43,13.94.143.214,13.94.150.186,13.94.151.22,13.69.121.116",
  "possibleOutboundIpAddresses": "13.69.68.43,13.94.143.214,13.94.150.186,13.94.151.22,13.69.121.116,13.94.137.26,40.68.188.89,13.94.142.40,13.94.144.225,104.214.221.75",
  "repositorySiteName": "<azure-webapp-name>",
  "reserved": true,
  "resourceGroup": "<resource-group-name>",
  "scmSiteAlsoStopped": false,
  "serverFarmId": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<resource-group-name>/providers/Microsoft.Web/serverfarms/<consumption-plan-name>",
  "siteConfig": {
    "acrUseManagedIdentityCreds": false,
    "acrUserManagedIdentityID": null,
    "alwaysOn": null,
    "apiDefinition": null,
    "apiManagementConfig": null,
    "appCommandLine": null,
    "appSettings": null,
    "autoHealEnabled": null,
    "autoHealRules": null,
    "autoSwapSlotName": null,
    "azureMonitorLogCategories": null,
    "connectionStrings": null,
    "cors": null,
    "customAppPoolIdentityAdminState": null,
    "customAppPoolIdentityTenantState": null,
    "defaultDocuments": null,
    "detailedErrorLoggingEnabled": null,
    "documentRoot": null,
    "experiments": null,
    "fileChangeAuditEnabled": null,
    "ftpsState": null,
    "functionsRuntimeScaleMonitoringEnabled": null,
    "handlerMappings": null,
    "healthCheckPath": null,
    "http20Enabled": null,
    "httpLoggingEnabled": null,
    "ipSecurityRestrictions": null,
    "javaContainer": null,
    "javaContainerVersion": null,
    "javaVersion": null,
    "limits": null,
    "linuxFxVersion": null,
    "loadBalancing": null,
    "localMySqlEnabled": null,
    "logsDirectorySizeLimit": null,
    "machineKey": null,
    "managedPipelineMode": null,
    "managedServiceIdentityId": null,
    "metadata": null,
    "minTlsVersion": null,
    "netFrameworkVersion": null,
    "nodeVersion": null,
    "numberOfWorkers": null,
    "phpVersion": null,
    "powerShellVersion": null,
    "preWarmedInstanceCount": null,
    "publishingPassword": null,
    "publishingUsername": null,
    "push": null,
    "pythonVersion": null,
    "remoteDebuggingEnabled": null,
    "remoteDebuggingVersion": null,
    "requestTracingEnabled": null,
    "requestTracingExpirationTime": null,
    "routingRules": null,
    "runtimeADUser": null,
    "runtimeADUserPassword": null,
    "scmIpSecurityRestrictions": null,
    "scmIpSecurityRestrictionsUseMain": null,
    "scmType": null,
    "tracingOptions": null,
    "use32BitWorkerProcess": null,
    "virtualApplications": null,
    "vnetName": null,
    "webSocketsEnabled": null,
    "websiteTimeZone": null,
    "winAuthAdminState": null,
    "winAuthTenantState": null,
    "windowsFxVersion": null,
    "xManagedServiceIdentityId": null
  },
  "slotSwapStatus": null,
  "snapshotInfo": null,
  "state": "Running",
  "suspendedTill": null,
  "tags": null,
  "targetSwapSlot": null,
  "trafficManagerHostNames": null,
  "type": "Microsoft.Web/sites",
  "usageState": "Normal"
}
```

Change WebApp Configuration to use our container for our own registry

```
az webapp config container set -n <azure-webapp-name> -g <resource-group-name> --docker-custom-image-name <container-registry-name>.azurecr.io/<docker-container-name>:v1 --docker-registry-server-url https://<container-registry-name>.azurecr.io --docker-registry-server-user <container-registry-name> --docker-registry-server-password <by-azure-generated-password-1>
```

Output:
```
[
  {
    "name": "WEBSITES_ENABLE_APP_SERVICE_STORAGE",
    "slotSetting": false,
    "value": "false"
  },
  {
    "name": "DOCKER_REGISTRY_SERVER_URL",
    "slotSetting": false,
    "value": "https://<container-registry-name>.azurecr.io"
  },
  {
    "name": "DOCKER_REGISTRY_SERVER_USERNAME",
    "slotSetting": false,
    "value": "<container-registry-name>"
  },
  {
    "name": "DOCKER_REGISTRY_SERVER_PASSWORD",
    "slotSetting": false,
    "value": null
  },
  {
    "name": "DOCKER_CUSTOM_IMAGE_NAME",
    "value": "DOCKER|<container-registry-name>.azurecr.io/<docker-container-name>:v1"
  }
]
```

It takes some time for the container to get started, but finally, you should be able to surf to: <azure-webapp-name>.azurewebsites.net.

Well done !

References:
* http://www.frankysnotes.com/2018/09/what-happen-when-you-mix-aspnet-core.html
* https://github.com/Azure/azure-cli/issues/7874 