# 🚀 ACTION REQUIRED - Complete Deployment Setup

**Status**: 🟡 Azure CLI Installed - Ready for Final Setup  
**Date**: February 20, 2026  
**Time**: ~5 minutes remaining

---

## 📍 Where You Are Now

✅ Azure CLI installed successfully  
✅ All code files ready  
✅ GitHub repository set up  
❌ GitHub Secrets NOT YET configured  
❌ Service Principal NOT YET created  

---

## 🎯 Do This RIGHT NOW (Takes 5 minutes)

### Step 1: Run the Setup Script

```powershell
cd d:\cldcpm\CLOUD-NBA-FINALS
.\create-service-principal.ps1
```

**This script will:**
1. Login to your Azure account (browser opens)
2. Create service principal automatically
3. Display all GitHub secrets you need
4. Save credentials to file

### Step 2: When Browser Opens

When the browser opens, you'll see:
```
https://microsoft.com/devicelogin
Enter device code: XXXXXXXX
```

Just follow the prompts to login with your Azure account.

### Step 3: After Script Completes

The script will show you:
- ✅ Service principal created
- ✅ Three GitHub secrets (copy these!)
- ✅ Where to add them

### Step 4: Add Secrets to GitHub

**Go to**: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions

For each of the 3 secrets shown by the script:
1. Click "New repository secret"
2. Copy the Name (e.g., `AZURE_CREDENTIALS`)
3. Paste the Value
4. Click "Add secret"

### Step 5: Push Your Changes

```powershell
git add .
git commit -m "fix: enable github actions deployment"
git push origin main
```

Then **watch**: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions

---

## ✨ What Happens Next

1. ✅ GitHub detects your push
2. ✅ Workflow runs automatically
3. ✅ Files upload to Azure
4. ✅ Website goes live!

**Result**: Your site at https://nbaoraclestats.z7.web.core.windows.net/ 🎉

---

## 🔧 If Script Doesn't Work

### Issue: "az command not found"
```powershell
# Update PATH manually:
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Try again:
az --version
```

### Issue: Login fails
```powershell
# Use device code instead:
az login --use-device-code
```

Then copy the code to: https://microsoft.com/devicelogin

### Issue: Service principal creation fails
- Make sure you have permissions to create service principals
- Contact your Azure admin if needed
- Verify subscription ID is correct: `2ee61742-e4b7-4e3a-90c9-11d13557d797`

---

## 📋 Manual Method (If Script Fails)

If the script doesn't work, manually run these commands:

```powershell
# 1. Update PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 2. Login to Azure
az login --use-device-code

# 3. Create service principal
az ad sp create-for-rbac `
  --name "github-actions-nba-oracle" `
  --role "Contributor" `
  --scopes "/subscriptions/2ee61742-e4b7-4e3a-90c9-11d13557d797" `
  --sdk-auth

# 4. Copy the entire JSON output
# 5. Add to GitHub as AZURE_CREDENTIALS secret
# 6. Add other two secrets (STORAGE_ACCOUNT, RESOURCE_GROUP)
```

---

## ✅ Verification Checklist

After setup:
- [ ] Ran `create-service-principal.ps1`
- [ ] Logged into Azure successfully
- [ ] Got service principal JSON
- [ ] Added AZURE_CREDENTIALS to GitHub
- [ ] Added STORAGE_ACCOUNT to GitHub
- [ ] Added RESOURCE_GROUP to GitHub
- [ ] Pushed code to main branch
- [ ] GitHub Actions workflow started
- [ ] Workflow completed successfully
- [ ] Website loads at Azure URL

---

## 🎯 Quick Reference

**Script**: `.\create-service-principal.ps1`  
**Secrets Location**: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions  
**Watch Deployment**: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions  
**Final Website**: https://nbaoraclestats.z7.web.core.windows.net/  

---

## 🚨 TLDR (Too Long; Didn't Read)

```powershell
# 1. Run setup
.\create-service-principal.ps1

# 2. When done, copy the secrets
# 3. Add them to GitHub: 
#    https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions

# 4. Push to deploy
git add .
git commit -m "fix: enable github actions"
git push origin main

# 5. Wait 2-3 minutes
# 6. Visit https://nbaoraclestats.z7.web.core.windows.net/
```

---

## 📞 Help

**Something wrong?**
1. Check [GITHUB_ACTIONS_FIX_GUIDE.md](GITHUB_ACTIONS_FIX_GUIDE.md)
2. Read the error message carefully
3. Try the manual method above
4. Check GitHub Actions logs for details

---

**You're almost there! Just run the script and follow the prompts!** 💪
