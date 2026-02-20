# ⚡ Quick Setup Guide - GitHub Actions + Azure Deployment

## 🎯 Do This Now (3 steps, ~5 minutes)

### Step 1: Run PowerShell Setup Script
```powershell
cd d:\cldcpm\CLOUD-NBA-FINALS
.\setup-github-actions.ps1
```

This script will:
- ✅ Check you have Azure CLI
- ✅ Login to your Azure account  
- ✅ Create service principal
- ✅ Show you the credentials JSON
- ✅ Optionally set GitHub secrets (if you have GitHub CLI)

### Step 2: Add Secrets to GitHub (if script didn't do it automatically)

If the script couldn't add secrets automatically, do this manually:

1. **Open**: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions

2. **Click**: "New repository secret"

3. **Add Secret #1 - AZURE_CREDENTIALS**:
   - Name: `AZURE_CREDENTIALS`
   - Value: Copy the JSON from the script output (the whole thing with `{}`)
   - Click "Add secret"

4. **Add Secret #2 - STORAGE_ACCOUNT**:
   - Name: `STORAGE_ACCOUNT`  
   - Value: `nbaoraclestats`
   - Click "Add secret"

5. **Add Secret #3 - RESOURCE_GROUP**:
   - Name: `RESOURCE_GROUP`
   - Value: `nba-finals`
   - Click "Add secret"

### Step 3: Push to Deploy

```powershell
cd d:\cldcpm\CLOUD-NBA-FINALS
git add .
git commit -m "fix: enable github actions with azure deployment"
git push origin main
```

Then watch: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions ✅

---

## 🚨 Prerequisites

Before running the script, you need:

### 1. Azure CLI
**Check if installed**:
```powershell
az --version
```

**If not installed**:
- Download: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows
- Or via chocolatey: `choco install azure-cli`
- Or via scoop: `scoop install azure-cli`

### 2. GitHub CLI (Optional but recommended)
**Check if installed**:
```powershell
gh --version
```

**If not installed**:
- Download: https://cli.github.com/
- Or via chocolatey: `choco install gh`
- Or via scoop: `scoop install gh`

---

## ✅ After Setup Completes

Your website will be live at:
```
https://nbaoraclestats.z7.web.core.windows.net/
```

And **every time you push**, it automatically deploys! 🎉

---

## 🔍 Verify Setup Worked

### Check GitHub Secrets Were Set
1. Go to: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions
2. You should see:
   - ✅ AZURE_CREDENTIALS (configured)
   - ✅ RESOURCE_GROUP (configured)
   - ✅ STORAGE_ACCOUNT (configured)

### Check Deployment Started
1. Go to: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions
2. Should see recent workflow run
3. Watch it complete ✅

### Check Website Updated
1. Visit: https://nbaoraclestats.z7.web.core.windows.net/
2. Hard refresh: **Ctrl+Shift+Delete** (clear cache) then **Ctrl+F5**
3. Should load with data from Azure! 🚀

---

## 🐛 Troubleshooting

### Script says "Azure CLI not found"
```powershell
# Install Azure CLI
# Option 1: Download installer
# https://aka.ms/installazurecliwindows

# Option 2: Use Chocolatey
choco install azure-cli

# Option 3: Use Scoop
scoop install azure-cli

# Then try again
.\setup-github-actions.ps1
```

### Script says "Failed to create service principal"
This usually means:
- You don't have permission to create service principals
- Ask your Azure admin for help
- OR increase permissions in Azure

### GitHub workflow still fails after secrets are set
1. Check the error in GitHub Actions UI
2. Common fixes:
   - Make sure AZURE_CREDENTIALS JSON is complete (includes `{}`)
   - Verify STORAGE_ACCOUNT matches your actual storage account
   - Verify RESOURCE_GROUP matches your actual resource group

### Website still shows old version
1. Hard refresh: **Ctrl+Shift+Delete** then **Ctrl+F5**
2. Wait 5-10 minutes (Azure propagation)
3. Check that GitHub Actions completed successfully

---

## 📋 Checklist

Before running setup:
- [ ] Azure CLI installed
- [ ] You can login to Azure
- [ ] You have GitHub repo access
- [ ] (Optional) GitHub CLI installed

After setup:
- [ ] Ran `setup-github-actions.ps1`
- [ ] Got service principal JSON
- [ ] Added 3 secrets to GitHub (or script did it)
- [ ] Made test commit and pushed
- [ ] GitHub Actions workflow succeeded
- [ ] Website loads at Azure URL

---

## 🎯 That's It!

Just run the script and follow the prompts. It will guide you through everything! 🚀

```powershell
.\setup-github-actions.ps1
```
