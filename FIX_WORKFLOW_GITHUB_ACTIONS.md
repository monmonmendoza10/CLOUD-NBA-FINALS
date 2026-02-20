# 🔧 Fix GitHub Actions Workflow - NBA Oracle Deployment

**Problem**: GitHub Actions workflow is failing to deploy to Azure  
**Date**: February 20, 2026  
**Status**: 🔴 Fixing

---

## 🎯 What's Wrong

Your workflow shows **4 failed deployments**. The issue is likely:
- ❌ Azure credentials not set up in GitHub Secrets
- ❌ Storage account name mismatch (z7 vs z5)
- ❌ Resource group not configured
- ❌ Missing AZURE_CREDENTIALS secret

---

## ✅ Step 1: Get Your Storage Account Info

First, find your actual storage account name and Azure details:

### Option A: Via Azure Portal
```
1. Go to https://portal.azure.com
2. Search for "Storage accounts"
3. Find your storage account (nbaoraclestats or similar)
4. Note the name exactly
5. Check the "Static website" endpoint (shows z5, z7, etc.)
```

### Option B: Via Azure CLI
```powershell
# List all storage accounts
az storage account list --query "[].name" -o table

# Get the endpoint for your account
az storage account show-blob-service-properties \
  --account-name nbaoraclestats \
  --resource-group your-resource-group
```

---

## ✅ Step 2: Create Azure Service Principal

You need AZURE_CREDENTIALS for GitHub Actions:

```powershell
# Set your values
$subscriptionId = "YOUR_SUBSCRIPTION_ID"
$resourceGroupName = "YOUR_RESOURCE_GROUP"  # e.g., "nba-finals"
$spName = "github-actions-nba-oracle"

# Log in to Azure
az login

# Create service principal
$sp = az ad sp create-for-rbac `
  --name $spName `
  --role "Storage Blob Data Contributor" `
  --scopes "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName" `
  --json

# Copy the output - you'll need it next
$sp | ConvertTo-Json
```

---

## ✅ Step 3: Set GitHub Secrets

1. **Go to GitHub**:
   - https://github.com/monmonmendoza10/CLOUD-NBA-FINALS
   - Click **Settings** → **Secrets and variables** → **Actions**

2. **Add these secrets**:

### Secret 1: AZURE_CREDENTIALS
```json
{
  "clientId": "YOUR_CLIENT_ID",
  "clientSecret": "YOUR_CLIENT_SECRET",
  "subscriptionId": "YOUR_SUBSCRIPTION_ID",
  "tenantId": "YOUR_TENANT_ID"
}
```
**Value**: Paste the entire JSON from the service principal creation

### Secret 2: STORAGE_ACCOUNT
```
Value: nbaoraclestats
(or whatever your storage account name is)
```

### Secret 3: RESOURCE_GROUP
```
Value: nba-finals
(or whatever your resource group name is)
```

### Secret 4: STORAGE_KEY (Optional)
```
Value: ConnectionString=DefaultEndpointProtocol=https;...
(Get this from Azure Portal → Storage Account → Access Keys)
```

---

## ✅ Step 4: Verify Secrets Are Set

```powershell
# From your repo directory
git config user.email "your-email@example.com"
git config user.name "Your Name"

# Make a small change to trigger workflow
echo "# Updated on $(date)" >> README.md
git add README.md
git commit -m "test: trigger deployment workflow"
git push origin main
```

Then check: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions

---

## ✅ Step 5: Check Workflow Status

Go to **Actions** tab and watch for:
- ✅ Green checkmark = Success
- 🔴 Red X = Failed (check logs)
- ⏳ Yellow circle = Running

---

## 🔍 Debug Failed Workflow

If it still fails, check the logs:

1. Click the failed workflow run
2. Click the **deploy** job
3. Expand each step to see error messages

### Common Errors:

**Error: "Could not get storage key!"**
```
Fix: Set STORAGE_KEY secret or ensure Azure credentials work
```

**Error: "Storage account not found!"**
```
Fix: Check STORAGE_ACCOUNT and RESOURCE_GROUP secrets match your Azure setup
```

**Error: "Invalid credentials"**
```
Fix: Regenerate AZURE_CREDENTIALS secret following Step 2
```

**Error: "Authentication failed"**
```
Fix: Make sure tenant and subscription IDs are correct in AZURE_CREDENTIALS
```

---

## 📊 Expected Workflow Steps

When workflow runs successfully, you should see:
```
✅ Checkout Code
✅ Azure Login
✅ Check Azure Login Status
✅ Use Storage Account Name (Direct)
✅ Get Storage Account Key
✅ Upload HTML Files
✅ Upload CSS Files
✅ Upload JavaScript Files
✅ Upload CSV Data Files
✅ Upload All HTML/CSS/JS Recursively
✅ Get Website URL
✅ Deployment Success
✅ Azure Logout
```

---

## 🌐 After Successful Deployment

Your site will be live at your storage account endpoint:

**Find your endpoint**:
```powershell
az storage account show \
  --name nbaoraclestats \
  --resource-group your-resource-group \
  --query "primaryEndpoints.web"
```

**Example**: 
```
https://nbaoraclestats.z7.web.core.windows.net/
https://nbaoraclestats.z5.web.core.windows.net/
```

---

## 🚀 Making Changes

Once workflow is fixed, deployment is automatic:

```bash
# Make any changes
vim src/script.js
vim ml/fixed_regular_season_data.csv
# ... etc

# Commit and push
git add .
git commit -m "feat: add new ML predictions"
git push origin main

# Workflow automatically runs and deploys!
# Check Actions tab to monitor progress
```

---

## 📋 Checklist

- [ ] Found storage account name (with correct z5/z7)
- [ ] Verified resource group exists in Azure
- [ ] Created service principal with correct permissions
- [ ] Set AZURE_CREDENTIALS secret in GitHub
- [ ] Set STORAGE_ACCOUNT secret in GitHub
- [ ] Set RESOURCE_GROUP secret in GitHub
- [ ] Made test commit to trigger workflow
- [ ] Watched workflow run and complete ✅
- [ ] Verified website deploys with new files
- [ ] Checked https://nbaoraclestats.z7.web.core.windows.net/

---

## 🎯 Quick Fix Commands

If you have Azure CLI installed and logged in:

```powershell
# Get all info needed
$storageAccount = "nbaoraclestats"
$resourceGroup = "nba-finals"

# Test connectivity
az storage account show -n $storageAccount -g $resourceGroup

# List what's uploaded
az storage blob list -c '$web' --account-name $storageAccount

# Check if CSV is there
az storage blob exists -c '$web' -n "ml/fixed_regular_season_data.csv" --account-name $storageAccount
```

---

## 📞 Still Having Issues?

1. **Check workflow file syntax**: `.github/workflows/deploy.yml` should be valid YAML
2. **Verify branch**: Make sure you're pushing to `main` branch (not `master`)
3. **Check file permissions**: Azure service principal needs Storage Blob Data Contributor role
4. **Regenerate credentials**: Service principals sometimes expire
5. **Check endpoint**: Make sure you're using the correct static website endpoint (not Blob endpoint)

---

## ✨ What Happens After Fix

Once workflow runs successfully:
- ✅ Your website updates automatically on every push
- ✅ CSV training data is deployed to Azure
- ✅ ML predictions work from Azure URL
- ✅ All users see the latest version
- ✅ No manual uploads needed

**Status**: Follow the steps above and your deployment will be fixed! 🚀
