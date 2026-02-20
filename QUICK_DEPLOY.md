# 🚀 Quick Deploy Commands - NBA Oracle to Azure

**For Immediate Deployment (Skip GitHub Actions Issues)**

---

## 📋 What You Need

```powershell
# Set these from your Azure resources:
$storageAccountName = "nbaoraclestats"      # Your storage account name
$resourceGroupName = "nba-finals"           # Your resource group
$containerName = '$web'                      # Don't change this
```

Get these values from:
1. Azure Portal → Storage accounts
2. Note the exact names
3. Run commands below

---

##🔑 Step 1: Get Storage Key

```powershell
# Login if needed
az login

# Get the first storage key
$key = az storage account keys list `
  --account-name nbaoraclestats `
  --resource-group nba-finals `
  --query "[0].value" -o tsv

# Verify you got it
Write-Host "Key length: $($key.Length)" 
```

---

## 📤 Step 2: Upload All Files

### Option A: Direct Upload Commands

```powershell
$storageAccount = "nbaoraclestats"
$resourceGroup = "nba-finals"
$key = az storage account keys list --account-name $storageAccount --resource-group $resourceGroup --query "[0].value" -o tsv

# Upload HTML
az storage blob upload --account-name $storageAccount --account-key $key --container-name '$web' --name "index.html" --file "index.html" --overwrite

# Upload CSS
az storage blob upload --account-name $storageAccount --account-key $key --container-name '$web' --name "src/styles.css" --file "src/styles.css" --overwrite

# Upload JavaScript
az storage blob upload --account-name $storageAccount --account-key $key --container-name '$web' --name "src/script.js" --file "src/script.js" --overwrite

az storage blob upload --account-name $storageAccount --account-key $key --container-name '$web' --name "src/predictor.js" --file "src/predictor.js" --overwrite

# Upload CSV Data (IMPORTANT!)
az storage blob upload --account-name $storageAccount --account-key $key --container-name '$web' --name "ml/fixed_regular_season_data.csv" --file "ml/fixed_regular_season_data.csv" --overwrite

# Upload Documentation
az storage blob upload --account-name $storageAccount --account-key $key --container-name '$web' --name "README.md" --file "README.md" --overwrite

az storage blob upload --account-name $storageAccount --account-key $key --container-name '$web' --name "PREDICTIONS_READY.md" --file "PREDICTIONS_READY.md" --overwrite
```

### Option B: Batch Upload Script

```powershell
# Run this PowerShell script directly:
.\deploy-direct.ps1 -StorageAccount "nbaoraclestats" -ResourceGroup "nba-finals"
```

### Option C: One-Liner Upload All

```powershell
$sa="nbaoraclestats"; $rg="nba-finals"; $key=$(az storage account keys list --account-name $sa --resource-group $rg --query "[0].value" -o tsv); Get-ChildItem -Path "." -Recurse -Include *.html,*.css,*.js,*.csv,*.md | ForEach-Object { $path=$_.FullName; $name=$path.Substring((Get-Location).Path.Length+1); $name=$name.Replace('\','/'); az storage blob upload --account-name $sa --account-key $key --container-name '$web' --name $name --file $path --overwrite }; Write-Host "✅ Done!"
```

---

## 🌐 Step 3: Verify Deployment

```powershell
# Check your storage account endpoint
az storage account show `
  --name nbaoraclestats `
  --resource-group nba-finals `
  --query "primaryEndpoints.web"

# Should output something like:
# https://nbaoraclestats.z7.web.core.windows.net/
```

---

## 📊 Check What's Uploaded

```powershell
# List all blobs in $web container
az storage blob list `
  --account-name nbaoraclestats `
  --container-name '$web' `
  --output table

# Check if specific file exists
az storage blob exists `
  --account-name nbaoraclestats `
  --container-name '$web' `
  --name "ml/fixed_regular_season_data.csv"

# Should return:
# "exists": true
```

---

## 🌍 Visit Your Site

```
https://nbaoraclestats.z7.web.core.windows.net/
```

**Important**: 
- Refresh with **Ctrl+F5** (hard refresh) to clear cache
- Check browser console (F12) for any errors
- Should see "✅ ML Model Ready" status

---

## 🔄 Auto-Deploy Every Push (Fix GitHub Actions)

Once manual deployment works, fix the workflow:

1. Check [FIX_WORKFLOW_GITHUB_ACTIONS.md](FIX_WORKFLOW_GITHUB_ACTIONS.md)
2. Set GitHub Secrets:
   - AZURE_CREDENTIALS
   - STORAGE_ACCOUNT
   - RESOURCE_GROUP
3. Next push automatically deploys!

---

## 🐛 Troubleshooting

### Error: "Invalid storage account name"
```powershell
# Check the exact name:
az storage account list | grep nbaoraclestats
```

### Error: "Invalid resource group"
```powershell
# List resource groups:
az group list --query "[].name"
```

### Error: "The specified container does not exist"
```powershell
# Enable static website (one-time only):
az storage blob service-properties update `
  --account-name nbaoraclestats `
  --static-website --index-document index.html --404-document index.html
```

### Files uploaded but not visible?
```powershell
# Clear CDN cache (if using one):
# Or wait 5-10 minutes for Azure propagation

# Force refresh in browser:
Ctrl+Shift+Delete (clear cache)
Then visit the URL again
```

---

## 📈 Performance Tips

### Parallel Upload
```powershell
# Upload multiple files in parallel for speed
$files = Get-ChildItem -Recurse -Include *.html,*.css,*.js,*.csv

$files | ForEach-Object -Parallel {
  $sa = "nbaoraclestats"
  $key = $using:key
  $path = $_.FullName
  $name = $path.Substring((Get-Location).Path.Length+1).Replace('\','/')
  
  az storage blob upload --account-name $sa --account-key $key `
    --container-name '$web' --name $name --file $path --overwrite
} -ThrottleLimit 5
```

---

## 🎯 Summary

**To deploy right now**:
```powershell
cd d:\cldcpm\CLOUD-NBA-FINALS
.\deploy-direct.ps1 -StorageAccount "nbaoraclestats" -ResourceGroup "nba-finals"
```

**Then visit**:
```
https://nbaoraclestats.z7.web.core.windows.net/
```

That's it! 🚀
