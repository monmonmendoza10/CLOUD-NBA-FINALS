# 🔐 GitHub Secrets Setup Guide

## ❌ Deployment Failed - Here's How to Fix It

Your GitHub Actions workflow failed because **GitHub Secrets are not configured**. Follow these steps to fix it.

---

## Step 1: Create Azure Service Principal

Open PowerShell and run:

```powershell
# Login to Azure first
az login

# Create service principal with Storage Blob permissions
az ad sp create-for-rbac `
  --name "github-nba-oracle" `
  --role "Storage Blob Data Contributor" `
  --scopes "/subscriptions/{subscription-id}/resourceGroups/nba-oracle-rg"
```

**Replace `{subscription-id}` with your actual subscription ID!**

You'll get output like:
```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "github-nba-oracle",
  "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

**Copy this entire JSON object** - you'll need it next.

---

## Step 2: Get Your Subscription ID

Find your subscription ID:

```powershell
az account show --query id -o tsv
```

---

## Step 3: Get Your Storage Account Name

If you already created a storage account:

```powershell
az storage account list --resource-group nba-oracle-rg --query "[0].name" -o tsv
```

---

## Step 4: Get Your Storage Account Key

```powershell
# Replace 'YourStorageAccountName' with actual name
az storage account keys list `
  --resource-group nba-oracle-rg `
  --account-name YourStorageAccountName `
  --query "[0].value" -o tsv
```

---

## Step 5: Add GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret below:

### Secret 1: AZURE_CREDENTIALS
- **Name**: `AZURE_CREDENTIALS`
- **Value**: Paste the entire JSON from Step 1
  ```json
  {
    "appId": "...",
    "displayName": "...",
    "password": "...",
    "tenant": "..."
  }
  ```

### Secret 2: RESOURCE_GROUP
- **Name**: `RESOURCE_GROUP`
- **Value**: `nba-oracle-rg`

### Secret 3: STORAGE_ACCOUNT
- **Name**: `STORAGE_ACCOUNT`
- **Value**: Your storage account name (from Step 3)

### Secret 4: SUBSCRIPTION_ID
- **Name**: `SUBSCRIPTION_ID`
- **Value**: Your subscription ID (from Step 2)

### Secret 5 (Optional): STORAGE_KEY
- **Name**: `STORAGE_KEY`
- **Value**: Your storage account key (from Step 4)

---

## Visual Guide: GitHub Secrets UI

```
Repository → Settings
                    ↓
            Secrets and Variables
                    ↓
              Actions
                    ↓
          New repository secret
                    ↓
        Fill in Name and Value
                    ↓
         Click "Add secret"
```

---

## ✅ How to Verify Setup

Once secrets are added, run the deployment:

```bash
# Option 1: Push to main branch
git add .
git commit -m "fix: setup github secrets"
git push origin main

# Option 2: Trigger manually
# Go to: Actions → Deploy NBA Oracle to Azure Storage → Run workflow
```

Watch the workflow at: **Actions** tab → **Deploy NBA Oracle to Azure Storage**

---

## 🐛 Still Having Issues?

### Issue: "Could not find storage account"
- **Solution**: Make sure storage account exists or set `STORAGE_ACCOUNT` secret

### Issue: "Unauthorized" or "Invalid credentials"
- **Solution**: Verify the `AZURE_CREDENTIALS` JSON is complete and correct

### Issue: "Resource group not found"
- **Solution**: Create the resource group first:
  ```powershell
  az group create --name nba-oracle-rg --location eastus
  ```

### Issue: "Storage account key is invalid"
- **Solution**: Get fresh key:
  ```powershell
  az storage account keys renew `
    --resource-group nba-oracle-rg `
    --account-name YourStorageAccountName `
    --key primary
  ```

---

## Next Steps

After secrets are configured:

1. ✅ Push code to main branch
2. ✅ Watch GitHub Actions deploy automatically
3. ✅ Visit: `https://YourStorageAccountName.z5.web.core.windows.net/`

---

## 📚 References

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [Azure Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)

---

**Still stuck?** Check [GITHUB_SECRETS_QUICK_FIX.md](GITHUB_SECRETS_QUICK_FIX.md) for a quicker version.
