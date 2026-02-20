# 🚨 URGENT: Fix Your GitHub Actions Deployment

**Your workflow is failing because:**
1. ❌ GitHub Secrets not configured properly
2. ❌ CSV data not being uploaded to Azure
3. ❌ Workflow needs AZURE_CREDENTIALS secret

---

## 🎯 Quick Fix (5 minutes)

### Step 1: Go to GitHub Settings

1. Open: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### Step 2: Add AZURE_CREDENTIALS Secret

You need to create an Azure Service Principal. **FOLLOW THESE EXACT STEPS:**

#### On Your Local Machine (PowerShell):

```powershell
# 1. Login to Azure
az login

# 2. Get your subscription ID
$subscriptionId = az account show --query id -o tsv
Write-Host "Subscription ID: $subscriptionId"

# 3. Create a service principal for GitHub Actions
az ad sp create-for-rbac `
  --name "github-actions-nba-oracle" `
  --role "Contributor" `
  --scopes "/subscriptions/$subscriptionId" `
  --sdk-auth
```

This will output JSON like:
```json
{
  "clientId": "00000000-0000-0000-0000-000000000000",
  "clientSecret": "XXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "subscriptionId": "00000000-0000-0000-0000-000000000000",
  "tenantId": "00000000-0000-0000-0000-000000000000",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/"
}
```

#### In GitHub:

1. Secret name: **AZURE_CREDENTIALS**
2. Secret value: **Paste the entire JSON above** (including the curly braces)
3. Click **Add secret**

### Step 3: Add STORAGE_ACCOUNT Secret

1. Click **New repository secret**
2. Name: **STORAGE_ACCOUNT**
3. Value: **nbaoraclestats** (or your actual storage account name)
4. Click **Add secret**

### Step 4: Add RESOURCE_GROUP Secret

1. Click **New repository secret**
2. Name: **RESOURCE_GROUP**
3. Value: **nba-finals** (or your actual resource group name)
4. Click **Add secret**

### Step 5: Trigger New Deployment

```bash
cd d:\cldcpm\CLOUD-NBA-FINALS
git add .
git commit -m "fix: configure github actions deployment"
git push origin main
```

Then watch the deployment:
- Go to: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions
- Click the latest workflow run
- Watch it deploy! ✅

---

## 🔍 Verify Your Secrets Are Set

Go to GitHub → Settings → Secrets and you should see:
```
✅ AZURE_CREDENTIALS (configured)
✅ RESOURCE_GROUP (configured)
✅ STORAGE_ACCOUNT (configured)
```

---

## 📊 What Happens Next  

When workflow runs successfully:
```
✅ Checkout Code
✅ Azure Login (using AZURE_CREDENTIALS)
✅ Upload HTML Files
✅ Upload CSS Files
✅ Upload JavaScript Files  
✅ Upload CSV Data Files ← IMPORTANT! This gets your ML training data
✅ Deployment Success!
```

---

## 🌐 After Deployment

Visit: **https://nbaoraclestats.z7.web.core.windows.net/**

The site should show:
- ✅ ML Model Ready (loading from Azure now!)
- ✅ All 30 NBA teams in standings
- ✅ CSV data loaded from Azure
- ✅ Real ML predictions working

---

## 🚫 If It Still Fails

Check the GitHub Actions logs:

1. Go to Actions tab
2. Click failed workflow
3. Click the "deploy" job
4. Expand step that failed
5. Look for error message

**Common errors & fixes:**

| Error | Fix |
|-------|-----|
| `invalid_client_id` | AZURE_CREDENTIALS JSON is malformed |
| `Storage account not found` | STORAGE_ACCOUNT secret name is wrong |
| `authentication failed` | AZURE_CREDENTIALS secret expired - regenerate |
| `Insufficient privileges` | Service principal needs higher permissions |

---

## 💡 Pro Tip: Manual Deployment (No GitHub)

If you're still having issues with GitHub Actions, deploy directly from your machine:

```powershell
# First install Azure CLI if not done:
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows

# Then:
az login
az storage blob upload-batch `
  --account-name nbaoraclestats `
  --destination '$web' `
  --source . `
  --pattern "*.html" --pattern "*.css" --pattern "*.js" --pattern "*.csv"
```

---

## ✅ Checklist

- [ ] Created Azure service principal
- [ ] Copied AZURE_CREDENTIALS JSON
- [ ] Added AZURE_CREDENTIALS to GitHub Secrets
- [ ] Added STORAGE_ACCOUNT to GitHub Secrets
- [ ] Added RESOURCE_GROUP to GitHub Secrets  
- [ ] Made a test commit and pushed to main
- [ ] Watched GitHub Actions run and succeed ✅
- [ ] Visited https://nbaoraclestats.z7.web.core.windows.net/
- [ ] Verified CSV data is loading (status shows "✅ ML Model Ready")

---

## 📞 Still Stuck?

Run these diagnostics:

```powershell
# Check you're in the right directory
Get-Location
# Should be: d:\cldcpm\CLOUD-NBA-FINALS

# Verify CSV exists
Test-Path ml/fixed_regular_season_data.csv
# Should be: True

# Check git status
git status
# Should show your files

# Check git remote
git remote -v
# Should show: origin... github.com/monmonmendoza10/CLOUD-NBA-FINALS
```

If all checks pass, your secrets should be the issue. Try regenerating AZURE_CREDENTIALS:

```powershell
az ad sp delete --id "github-actions-nba-oracle"
# Then re-run the creation command from Step 2 above
```

---

## 🎉 You're Almost There!

Once GitHub Actions is working:
- Every `git push` automatically deploys
- CSV data updates on Azure
- Website serves ML predictions
- No manual uploads needed

**The fixes above should resolve your deployment issues!** 🚀
