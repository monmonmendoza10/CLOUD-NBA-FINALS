# 🔧 Troubleshooting Guide

## Common Issues & Solutions

---

## GitHub Actions Deployment Failures

### ❌ Error: "AZURE_CREDENTIALS not found"

**Cause**: GitHub Secrets not configured.

**Solution**:
1. Follow [SETUP_GITHUB_SECRETS.md](SETUP_GITHUB_SECRETS.md)
2. Add all required secrets to GitHub
3. Retry deployment

---

### ❌ Error: "Could not get storage key"

**Cause**: Storage account doesn't exist or isn't accessible.

**Solution**:
```powershell
# Create storage account first
az storage account create \
  --name nbaoraclestorage \
  --resource-group nba-oracle-rg \
  --location eastus \
  --sku Standard_LRS

# Enable static website
az storage blob service-properties update \
  --account-name nbaoraclestorage \
  --static-website \
  --index-document index.html
```

---

### ❌ Error: "Resource group not found"

**Cause**: Resource group doesn't exist.

**Solution**:
```powershell
# Create resource group
az group create \
  --name nba-oracle-rg \
  --location eastus
```

---

### ❌ Error: "Unauthorized - Invalid credentials"

**Cause**: Service Principal credentials expired or invalid.

**Solution**:
```powershell
# Create new service principal
az ad sp create-for-rbac \
  --name "github-nba-oracle" \
  --role "Storage Blob Data Contributor" \
  --scopes "/subscriptions/{subscription-id}/resourceGroups/nba-oracle-rg"

# Update AZURE_CREDENTIALS secret with new JSON
```

---

## Local Development Issues

### ❌ "Port 8000 already in use"

**Solution**:
```bash
# Using different port
python -m http.server 8080  # Use port 8080

# Or kill existing process
# On Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# On macOS/Linux:
lsof -i :8000
kill -9 <PID>
```

---

### ❌ "Python not found"

**Solution**:
```bash
# Install Python from python.org
# Or use Node.js http-server
npx http-server . -p 8000
```

---

## ML Model Issues

### ❌ "ModuleNotFoundError: No module named 'sklearn'"

**Solution**:
```bash
# Install dependencies
pip install -r requirements.txt

# Or install individually
pip install scikit-learn pandas numpy
```

---

### ❌ "Model training fails with 'Empty DataFrame'"

**Cause**: Sample data file is missing or empty.

**Solution**:
1. Check `ml/sample_data.csv` exists
2. Verify CSV format:
   ```
   Team,Wins,Losses,ThreePointPct,DefensiveRating,MadePlayoffs
   Boston Celtics,58,24,38.2,110.5,1
   ...
   ```
3. Run training: `python ml/train_model.py`

---

## Website Issues

### ❌ "Website shows blank page or 404"

**Cause**: Files not uploaded or storage website not enabled.

**Solution**:
```powershell
# Check if static website is enabled
az storage blob service-properties show \
  --account-name nbaoraclestorage

# Enable if not
az storage blob service-properties update \
  --account-name nbaoraclestorage \
  --static-website \
  --index-document index.html

# Re-upload files
az storage blob upload-batch \
  --account-name nbaoraclestorage \
  --destination '$web' \
  --source .
```

---

### ❌ "Styles not loading (CSS broken)"

**Cause**: CSS file path issue or CORS problem.

**Solution**:
1. Verify `src/styles.css` is uploaded:
   ```powershell
   az storage blob list \
     --account-name nbaoraclestorage \
     --container-name '$web'
   ```

2. Check browser console (F12) for errors
3. Verify CSS file path in HTML:
   ```html
   <link rel="stylesheet" href="src/styles.css">
   ```

---

### ❌ "JavaScript predictions not working"

**Cause**: Script not loaded or ML endpoint not configured.

**Solution**:
1. Check browser console (F12)
2. Verify `src/script.js` is uploaded
3. For now, mock predictions work without Azure
4. To enable real ML:
   - Complete Phase 3 (ML training)
   - Update ML_API_KEY secret
   - Replace mock function with real endpoint

---

## Azure ML Issues

### ❌ "ML endpoint not responding"

**Solution**:
```bash
# Check endpoint status
az ml online-endpoint show \
  --name nba-oracle-endpoint

# Check deployment status
az ml online-deployment get-logs \
  --name playoff-deploy \
  --endpoint-name nba-oracle-endpoint
```

---

### ❌ "Model accuracy very low"

**Cause**: Insufficient or poor quality training data.

**Solutions**:
1. **Add more training samples**:
   - Include multiple seasons
   - Expand ml/sample_data.csv

2. **Feature engineering**:
   - Add more statistical features
   - Remove irrelevant features

3. **Try different algorithm**:
   - Gradient Boosting
   - Neural Networks
   - XGBoost

4. **Hyperparameter tuning**:
   - Adjust max_depth
   - Increase n_estimators
   - Change min_samples_split

---

## Git & GitHub Issues

### ❌ "Git not found"

**Solution**:
```bash
# Install Git from git-scm.com
# Or verify installation
git --version
```

---

### ❌ "Failed to push to GitHub"

**Cause**: Authentication or remote issues.

**Solution**:
```bash
# Re-add remote
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/CLOUD-NBA-FINALS.git

# Configure credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Try push again
git push -u origin main
```

---

### ❌ "Large files rejected by GitHub"

**Cause**: File size > 25MB or blocked patterns.

**Solution**:
1. Remove large files from git
2. Add to `.gitignore`:
   ```
   *.pkl
   *.large
   ml/models/
   ```
3. Store models in Azure instead

---

## Performance Issues

### ❌ "Website loads slowly"

**Solution**:
1. Check Azure Storage location
2. Enable Azure CDN:
   ```powershell
   az cdn profile create \
     --resource-group nba-oracle-rg \
     --name nba-oracle-cdn
   ```
3. Minify CSS/JS
4. Optimize image sizes

---

### ❌ "ML predictions are slow"

**Solution**:
1. Check endpoint compute resources
2. Increase instance count:
   ```bash
   az ml online-deployment update \
     --name playoff-deploy \
     --endpoint-name nba-oracle-endpoint \
     --instance-count 2
   ```
3. Use caching for frequent predictions

---

## Debugging Steps

### General Troubleshooting Checklist

1. **Check error messages** - Read them carefully!
2. **Check logs**:
   - GitHub Actions: Actions tab
   - Azure: Azure Portal
   - Browser: F12 console
3. **Verify prerequisites**:
   - Azure account active
   - Azure CLI logged in
   - GitHub secrets configured
4. **Test locally first**:
   - Run `npx http-server . -p 8000`
   - Verify HTML/CSS/JS work
5. **Check resource status**:
   ```powersh
   az resource list --resource-group nba-oracle-rg
   ```

---

## Getting Help

### Resources

- 📖 [README.md](README.md) - Full documentation
- 🚀 [QUICKSTART.md](QUICKSTART.md) - Quick reference
- 📋 [SETUP_GITHUB_SECRETS.md](SETUP_GITHUB_SECRETS.md) - GitHub setup
- 🏗️ [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - System design

### External Help

- [Azure Doc](https://docs.microsoft.com/azure/)
- [GitHub Actions Help](https://docs.github.com/actions)
- [scikit-learn Docs](https://scikit-learn.org/)
- [Stack Overflow](https://stackoverflow.com/)

---

**Still stuck?** Create an issue on GitHub with:
- Error message (full text)
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, tools versions)
