# 🔐 QUICK FIX: GitHub Deployment Not Working

## ❌ Your Current Issue

Your GitHub Actions workflow is failing because **GitHub Secrets are missing**.

Look at your Actions tab - you have 2 failed runs. This is because the workflow needs credentials to access Azure.

---

## ⚡ FASTEST FIX (5 minutes)

### Step 1: Get Your Azure Subscription ID

Copy this command and run it in PowerShell:

```powershell
az account show --query id -o tsv
```

**It will output something like**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

**Copy this value** ← You need it!

---

### Step 2: Create Azure Service Principal

Run this in PowerShell (replace `{subscription-id}` with your ID from Step 1):

```powershell
az ad sp create-for-rbac `
  --name "github-nba-oracle" `
  --role "Storage Blob Data Contributor" `
  --scopes "/subscriptions/{subscription-id}/resourceGroups/nba-oracle-rg"
```

**You'll get back JSON that looks like:**
```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "github-nba-oracle",
  "password": "veryLongPasswordString",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

**Copy the ENTIRE JSON** ← You need this!

---

### Step 3: Create Resource Group (if needed)

```powershell
az group create --name nba-oracle-rg --location eastus
```

---

### Step 4: Create Storage Account

```powershell
$storageAccount = "nbaoraclestorage$(Get-Random -Maximum 9999)"

az storage account create `
  --name $storageAccount `
  --resource-group nba-oracle-rg `
  --location eastus `
  --sku Standard_LRS `
  --kind StorageV2

# Enable static website
az storage blob service-properties update `
  --account-name $storageAccount `
  --static-website `
  --index-document index.html

# Output your storage account name (save this!)
Write-Host "Your storage account: $storageAccount"
```

**Copy the storage account name** ← You need this!

---

### Step 5: Add GitHub Secrets

1. **Go to**: Your GitHub repo
2. **Click**: Settings → Secrets and variables → Actions
3. **Click**: New repository secret

**Add these 4 secrets** (click "New repository secret" for each):

#### Secret 1: AZURE_CREDENTIALS
- **Name**: `AZURE_CREDENTIALS`
- **Value**: Paste the entire JSON from Step 2

#### Secret 2: STORAGE_ACCOUNT
- **Name**: `STORAGE_ACCOUNT`  
- **Value**: Your storage account name from Step 4 (e.g., `nbaoraclestorage1234`)

#### Secret 3: RESOURCE_GROUP
- **Name**: `RESOURCE_GROUP`
- **Value**: `nba-oracle-rg`

#### Secret 4: SUBSCRIPTION_ID
- **Name**: `SUBSCRIPTION_ID`
- **Value**: Your subscription ID from Step 1

---

### Step 6: Push Code & Deploy

```bash
# Make a small change (even just a comment)
git add .
git commit -m "fix: add github secrets for deployment"
git push origin main
```

**Go to** GitHub Actions tab and watch it deploy! ✅

---

## 📸 Visual Guide

### Where to Add GitHub Secrets:

```
Your Repo
    ↓
Settings (top right)
    ↓
Secrets and variables (left menu)
    ↓
Actions
    ↓
Green "New repository secret" button
    ↓
Fill in Name and Value
    ↓
Click "Add secret"
```

Repeat for each of the 4 secrets above.

---

## ✅ Verify It Works

1. **Go to** Actions tab
2. **Click** the latest "Deploy NBA Oracle to Azure Storage" run
3. **If green ✅**: Success! Check your website at `https://YOURSTORAGENAME.z5.web.core.windows.net/`
4. **If still red ❌**: Message me with the error

---

## 🚨 Common Mistakes

**❌ Mistake 1**: Pasting only part of the JSON
- ✅ **Fix**: Copy the ENTIRE JSON including curly braces

**❌ Mistake 2**: Wrong storage account name
- ✅ **Fix**: Use the exact name output from Step 4

**❌ Mistake 3**: Missing resource group
- ✅ **Fix**: Run Step 3 first!

---

## 🆘 Still Not Working?

If it still fails, check the error in GitHub Actions:

1. Click your failed workflow run
2. Click the "deploy" job
3. Scroll down to see the actual error
4. Message me with that error message

---

## ⏱️ What Happens After Secrets Are Set

```
You push code
    ↓ (seconds later)
GitHub Actions starts
    ↓
Checks Azure Secrets (✅ now passes!)
    ↓
Authenticates to Azure
    ↓
Gets storage account
    ↓
Uploads HTML/CSS/JS files
    ↓
Website is LIVE! 🌐
```

---

**That's it! After adding the 4 secrets and pushing, your GitHub deployment should work.** 🎉

Message me if you hit any errors!
