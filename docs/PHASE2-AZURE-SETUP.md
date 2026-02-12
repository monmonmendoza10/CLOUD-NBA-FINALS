# PHASE 2: Azure Infrastructure Setup

## 🎯 Objective
Deploy all necessary Azure resources for hosting and ML operations.

## 📋 Prerequisites
- Azure for Students account
- Azure CLI installed
- PowerShell 5.1 or higher
- Appropriate Azure permissions

## 🚀 Steps

### 1. Set Environment Variables

```powershell
# Set your configuration
$subscriptionId = "your-subscription-id"
$resourceGroup = "nba-oracle-rg"
$location = "eastus"
$storageAccount = "nbaoraclestorage$(Get-Random -Maximum 9999)"
$mlWorkspace = "nba-oracle-ml"
$keyVault = "nba-oracle-kv"

# Set default subscription
az account set --subscription $subscriptionId
```

### 2. Create Resource Group

```powershell
az group create `
  --name $resourceGroup `
  --location $location
```

### 3. Create Storage Account

```powershell
az storage account create `
  --name $storageAccount `
  --resource-group $resourceGroup `
  --location $location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --access-tier Hot

# Enable static website hosting
az storage blob service-properties update `
  --account-name $storageAccount `
  --static-website `
  --index-document index.html `
  --404-document index.html

# Get the website endpoint
$website = "https://$storageAccount.z5.web.core.windows.net/"
Write-Host "Website URL: $website"
```

### 4. Upload Website Files

```powershell
# Get storage key
$storageKey = (az storage account keys list `
  --account-name $storageAccount `
  --resource-group $resourceGroup `
  --query "[0].value" -o tsv)

# Upload files
az storage blob upload-batch `
  --account-name $storageAccount `
  --account-key $storageKey `
  --destination '$web' `
  --source . `
  --pattern "*.html" `
  --pattern "src/*"
```

### 5. Create Azure ML Workspace

```powershell
# Create storage account for ML
$mlStorageAccount = "nbamlstorage$(Get-Random -Maximum 9999)"

az storage account create `
  --name $mlStorageAccount `
  --resource-group $resourceGroup `
  --location $location `
  --sku Standard_LRS `
  --kind StorageV2

# Create ML workspace
az ml workspace create `
  --name $mlWorkspace `
  --resource-group $resourceGroup `
  --location $location
```

### 6. Create Key Vault

```powershell
az keyvault create `
  --resource-group $resourceGroup `
  --name $keyVault `
  --location $location

# Store secrets
az keyvault secret set `
  --vault-name $keyVault `
  --name "storage-key" `
  --value $storageKey

az keyvault secret set `
  --vault-name $keyVault `
  --name "ml-key" `
  --value "your-ml-key"
```

## ✅ Verification

```powershell
# Check storage account
az storage account show `
  --name $storageAccount `
  --query "properties.primaryEndpoints"

# Check ML workspace
az ml workspace list `
  --resource-group $resourceGroup

# Check Key Vault
az keyvault secret list `
  --vault-name $keyVault
```

## 📊 Cost Estimation

- **Storage Account**: ~$0.023/GB/month
- **ML Workspace**: Free (usage-based)
- **Key Vault**: $0.6/month
- **Total Est.**: <$5/month for Students

## 🔄 IaC with Bicep

```powershell
# Deploy using Bicep template
az deployment group create `
  --resource-group $resourceGroup `
  --template-file infrastructure/deploy.bicep

# Get outputs
az deployment group show-outputs `
  --resource-group $resourceGroup `
  --name deploy
```

## 🔐 Security Best Practices

- ✅ Enable HTTPS only on storage
- ✅ Use managed identities
- ✅ Store secrets in Key Vault
- ✅ Enable diagnostic logging
- ✅ Use SAS tokens for limited access

## Next Phase
→ Move to [PHASE3-ML-SETUP.md](PHASE3-ML-SETUP.md) for ML model training
