# PHASE 4: CI/CD with GitHub Actions

## 🎯 Objective
Automate deployment to Azure Storage on every code push.

## 📋 Prerequisites
- GitHub repository
- Azure Service Principal
- GitHub Secrets configured

## 🚀 Steps

### 1. Create Azure Service Principal

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "github-nba-oracle" \
  --role "Storage Blob Data Contributor" \
  --scopes "/subscriptions/{subscription-id}/resourceGroups/nba-oracle-rg"
```

**Output:**
```json
{
  "appId": "...",
  "password": "...",
  "tenant": "..."
}
```

### 2. Add GitHub Secrets

**Go to GitHub → Repository → Settings → Secrets and Variables → Actions**

Add these secrets:
```
AZURE_CREDENTIALS = {entire json output from above}
STORAGE_ACCOUNT = nbaoraclestorage****
RESOURCE_GROUP = nba-oracle-rg
SUBSCRIPTION_ID = your-subscription-id
ML_API_KEY = your-ml-endpoint-key
```

### 3. Workflow File

**Location**: `.github/workflows/deploy.yml` ✅ (Already created)

The workflow includes:
- ✅ Azure login
- ✅ Upload HTML/CSS/JS files
- ✅ Set cache headers
- ✅ Health checks
- ✅ Automatic deployment on push

### 4. Deploy Files to Git

```bash
# Initialize git (if needed)
git init
git add .
git commit -m "Initial commit: NBA Oracle Phase 1-4"

# Add remote and push
git remote add origin https://github.com/your-username/CLOUD-NBA-FINALS.git
git branch -M main
git push -u origin main
```

### 5. Monitor Deployment

**GitHub Actions Dashboard:**
1. Go to your repo
2. Click "Actions" tab
3. Watch the "Deploy NBA Oracle to Azure Storage" workflow
4. Check for ✅ or ❌ status

**View Logs:**
```
GitHub → Actions → Deploy NBA Oracle → Run → View deployment logs
```

## 🔄 Workflow Triggers

The deployment runs on:
- ✅ Push to `main` branch
- ✅ Manual trigger (via "Run workflow")

**To trigger manually:**
1. Go to Actions tab
2. Select "Deploy NBA Oracle to Azure Storage"
3. Click "Run workflow"

## 📝 Git Workflow

### Making Changes:

```bash
# Create feature branch
git checkout -b feature/add-live-standings

# Make changes to HTML/CSS/JS
echo "Update code..."

# Commit
git add .
git commit -m "feat: add live standings API integration"

# Push (auto-deploys on PR merge to main)
git push origin feature/add-live-standings
```

### Pull Request Process:

1. Push to feature branch
2. Create PR on GitHub
3. Code review
4. Merge to main
5. Automatic deployment triggers
6. Website updates in ~2 minutes

## ✅ Deployment Checklist

Before each deployment, ensure:
- [ ] All HTML is valid
- [ ] CSS files compile without errors
- [ ] JavaScript has no console errors
- [ ] All links work correctly
- [ ] Responsive design tested
- [ ] API endpoints are accessible
- [ ] Secrets are not committed

## 🔐 Security in CI/CD

```yaml
# Always mask sensitive data
echo "::add-mask::${{ secrets.ML_API_KEY }}"

# Never log credentials
# ❌ Wrong: echo $API_KEY
# ✅ Right: echo "Connected successfully"

# Use least privilege roles
# ✅ Storage Blob Data Contributor (minimal)
# ❌ Contributor (too broad)
```

## 📊 Pipeline Metrics

**Expected Deployment Time:**
- Upload files: 10-15 seconds
- Health checks: 5-10 seconds
- **Total: ~20-30 seconds**

**Success Rate Target:**
- 99%+ successful deployments
- Automated rollback on failure

## 🐛 Troubleshooting

**Issue**: "Authentication failed"
```bash
# Solution: Regenerate service principal
az ad sp create-for-rbac \
  --name "github-nba-oracle" \
  --overwrite \
  --role "Storage Blob Data Contributor"
```

**Issue**: "File not found in storage"
```bash
# Solution: Check upload pattern
# In workflow, ensure correct paths:
az storage blob upload-batch \
  --source . \
  --pattern "*.html" \
  --pattern "src/*"
```

**Issue**: "Website shows old content"
```bash
# Solution: Clear browser cache
# Or add cache-busting query parameters:
<link rel="stylesheet" href="src/styles.css?v=2">
```

## 🚀 Advanced Workflows

### Multi-Environment Deployment

```yaml
jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    # Deploy to dev storage account
  
  deploy-prod:
    if: github.ref == 'refs/heads/main'
    needs: test
    # Deploy to production storage account
```

### Automated Testing

```yaml
- name: Run Tests
  run: |
    npm install
    npm test

- name: Check HTML Validity
  run: |
    npm install html-validate
    html-validate index.html
```

### Performance Monitoring

```yaml
- name: Lighthouse CI
  uses: treosh/lighthouse-ci-action@v10
  with:
    configPath: './lighthouserc.json'
```

## 📚 References

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Azure Login Action](https://github.com/marketplace/actions/azure-login)
- [Azure CLI in Actions](https://github.com/marketplace/actions/azure-cli-action)

## ✅ Phase 4 Complete!

Your NBA Oracle is now:
- ✅ Deployed on Azure Storage
- ✅ Auto-deploying via GitHub Actions
- ✅ Running with ML predictions
- ✅ Production-ready

---

## 🎉 Full Stack Summary

| Phase | Component | Status |
|-------|-----------|--------|
| 1 | Frontend UI | ✅ Complete |
| 2 | Azure Infrastructure | ✅ Complete |
| 3 | ML Model & Endpoint | ✅ Complete |
| 4 | CI/CD Pipeline | ✅ Complete |

**Website URL**: `https://nbaoraclestorage****.z5.web.core.windows.net/`

**Endpoint**: `/score` on your ML workspace

**Next**: Monitor, optimize, and enhance with real NBA APIs!
