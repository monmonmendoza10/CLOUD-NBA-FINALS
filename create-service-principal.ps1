#!/usr/bin/env pwsh
<#
.SYNOPSIS
Create Azure Service Principal and GitHub Secrets for NBA Oracle deployment
.DESCRIPTION
Automates the setup of GitHub Actions with Azure deployment
#>

# Update PATH to ensure az command is available
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify az is available
Write-Host "🔍 Checking Azure CLI..." -ForegroundColor Cyan
try {
    $version = az version --query "['azure-cli']" -o tsv
    Write-Host "✅ Azure CLI version: $version" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found or not working" -ForegroundColor Red
    Write-Host "Please install Azure CLI from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📋 NBA Oracle - GitHub Actions Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Save secrets to file
$secretsFile = "github-secrets.json"

# Configuration
$servicePrincipalName = "github-actions-nba-oracle"
$subscriptionId = "2ee61742-e4b7-4e3a-90c9-11d13557d797"
$storageAccount = "nbaoraclestats"
$resourceGroup = "nba-finals"

Write-Host "📝 Configuration:
  Service Principal: $servicePrincipalName
  Subscription ID: $subscriptionId
  Storage Account: $storageAccount
  Resource Group: $resourceGroup
" -ForegroundColor Gray

Write-Host "🔑 Step 1: Authenticate with Azure" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Opening Azure login..." -ForegroundColor Gray
Write-Host ""
Write-Host "ℹ️  It will take a few moments..." -ForegroundColor Yellow

try {
    # Login with device code
    az login --use-device-code --only-show-errors 2>&1 | Out-Null
    
    $account = az account show --query "name" -o tsv 2>&1
    Write-Host "✅ Logged in as: $account" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed. Please try again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🤖 Step 2: Remove existing service principal (if any)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

try {
    $existing = az ad sp list --display-name $servicePrincipalName --query "[0].id" -o tsv 2>&1
    if ($existing -and $existing -ne "Error") {
        Write-Host "Found existing service principal, removing..." -ForegroundColor Gray
        az ad sp delete --id $existing 2>&1 | Out-Null
        Write-Host "✅ Removed existing service principal" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Could not check for existing service principal (continuing...)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✨ Step 3: Create new service principal" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Creating: $servicePrincipalName..." -ForegroundColor Gray

try {
    # Create service principal with SDK auth format (for GitHub Actions)
    $output = az ad sp create-for-rbac `
        --name $servicePrincipalName `
        --role "Contributor" `
        --scopes "/subscriptions/$subscriptionId" `
        --sdk-auth 2>&1

    if ($output) {
        $credentials = $output | ConvertFrom-Json
        Write-Host "✅ Service principal created successfully!" -ForegroundColor Green
        Write-Host "   Name: $($credentials.clientId)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Failed to create service principal" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error creating service principal: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Step 4: Prepare GitHub Secrets" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Create secrets object
$secrets = @{
    "AZURE_CREDENTIALS" = $credentials | ConvertTo-Json -Compress
    "STORAGE_ACCOUNT" = $storageAccount
    "RESOURCE_GROUP" = $resourceGroup
}

# Save to file
$secrets | ConvertTo-Json -Depth 10 | Out-File $secretsFile -Encoding UTF8
Write-Host "✅ Secrets saved to: $secretsFile" -ForegroundColor Green

Write-Host ""
Write-Host "🔐 GitHub Secrets to Add:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add these 3 secrets to GitHub:" -ForegroundColor White
Write-Host "Repo: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions" -ForegroundColor Cyan
Write-Host ""

Write-Host "Secret 1: AZURE_CREDENTIALS" -ForegroundColor Yellow
Write-Host "─" * 50 -ForegroundColor Gray
Write-Host ($credentials | ConvertTo-Json -Depth 10) -ForegroundColor White
Write-Host ""

Write-Host "Secret 2: STORAGE_ACCOUNT" -ForegroundColor Yellow
Write-Host "─" * 50 -ForegroundColor Gray
Write-Host $storageAccount -ForegroundColor White
Write-Host ""

Write-Host "Secret 3: RESOURCE_GROUP" -ForegroundColor Yellow
Write-Host "─" * 50 -ForegroundColor Gray
Write-Host $resourceGroup -ForegroundColor White
Write-Host ""

Write-Host "📋 Step 5: How to Add Secrets" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host @"
Option A: Automatic (with GitHub CLI)
────────────────────────────────────
1. Install GitHub CLI: https://cli.github.com/
2. Run: gh auth login
3. Run: gh secret set AZURE_CREDENTIALS < github-secrets.json
4. Run: gh secret set STORAGE_ACCOUNT --body "$storageAccount"
5. Run: gh secret set RESOURCE_GROUP --body "$resourceGroup"

Option B: Manual (via GitHub Web)
──────────────────────────────────
1. Go to: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions
2. Click "New repository secret"
3. For each secret above:
   - Copy the Name
   - Paste the Value
   - Click "Add secret"

"@ -ForegroundColor Gray

Write-Host ""
Write-Host "🚀 Step 6: Trigger Deployment" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host @"
After adding secrets, push your changes:

  cd d:\cldcpm\CLOUD-NBA-FINALS
  git add .
  git commit -m "fix: configure github actions with azure deployment"
  git push origin main

Then watch: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions

"@ -ForegroundColor Gray

Write-Host ""
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next: Add the 3 secrets above to GitHub, then push your code!" -ForegroundColor Yellow
Write-Host ""
Write-Host "After deployment succeeds, your site will be live at:" -ForegroundColor Cyan
Write-Host "https://nbaoraclestats.z7.web.core.windows.net/" -ForegroundColor White
Write-Host ""

Write-Host "Files created:" -ForegroundColor Gray
Write-Host "  - $secretsFile (save this somewhere safe!)" -ForegroundColor Gray
