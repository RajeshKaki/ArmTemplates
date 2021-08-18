#Deploys the main Template
$resourceGroupName = "rg-arm-linked"
$deploymentName = "DeployLinkedArmTemplate"
$location = "southindia"
$templateStoreStorageName = "starmstore$location"
$containerName = "templates"
Write-Host "Deploys main template that deploy the linked Storage account template"

$key = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName `
       -Name $templateStoreStorageName).Value[0]
$context = New-AzStorageContext -StorageAccountName $templateStoreStorageName `
           -StorageAccountKey $key

$mainTemplateUri = $context.BlobEndPoint + "$containerName/mainTemplate.json"
write-host "main template uri: $mainTemplateUri"
write-host "Deployment started..."
$sasToken = New-AzStorageContainerSASToken `
            -Context $context `
            -Container $containerName `
            -Permission r `
            -ExpiryTime (Get-Date).AddHours(2.0)
New-AzResourceGroupDeployment -Name $deploymentName `
-ResourceGroupName  $resourceGroupName `
-TemplateUri $mainTemplateUri `
-QueryString $sasToken.Substring(1) `
-Verbose
