# NBA Oracle - GitHub Actions Azure Setup (Non-Interactive)

# Add Azure CLI to PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$subscriptionId = "2ee61742-e4b7-4e3a-90c9-11d13557d797"
$servicePrincipalName = "github-actions-nba-oracle"
$storageAccount = "nbaoraclestats"
$resourceGroup = "nba-finals"

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "NBA Oracle GitHub Actions Setup" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "- Service Principal: $servicePrincipalName"
Write-Host "- Subscription: $subscriptionId"
Write-Host "- Storage Account: $storageAccount"
Write-Host "- Resource Group: $resourceGroup"
Write-Host ""

# Step 1: Check if already logged in
Write-Host "[1/4] Checking Azure authentication..." -ForegroundColor Green
try {
    $currentAccount = az account show --query "id" -o tsv 2>$null
    if ($currentAccount) {
        Write-Host "Already authenticated" -ForegroundColor Green
    } else {
        Write-Host "Need to authenticate" -ForegroundColor Yellow
        az login --use-device-code
    }
} catch {
    Write-Host "Logging in to Azure (device code)..." -ForegroundColor Cyan
    az login --use-device-code
}

# Step 2: Set the correct subscription
Write-Host ""
Write-Host "[2/4] Setting subscription..." -ForegroundColor Green
az account set --subscription $subscriptionId
$sub = az account show --query "name" -o tsv
Write-Host "Using subscription: $sub" -ForegroundColor Green

# Step 3: Create Service Principal
Write-Host ""
Write-Host "[3/4] Creating service principal..." -ForegroundColor Green
Write-Host "Service Principal Name: $servicePrincipalName" -ForegroundColor Cyan

$spJson = az ad sp create-for-rbac --name $servicePrincipalName --role contributor --scopes "/subscriptions/$subscriptionId" --json-auth 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Service principal might already exist (checking...)" -ForegroundColor Yellow
    $existing = az ad sp list --filter "displayName eq '$servicePrincipalName'" --query "[0].id" -o tsv 2>$null
    if ($existing) {
        Write-Host "Service principal exists: $existing" -ForegroundColor Green
        $resetOutput = az ad sp credential reset --id $existing --years 2 2>&1
        $spJson = $resetOutput
    } else {
        Write-Host "Failed to create/find service principal" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Service principal created successfully" -ForegroundColor Green
}

# Step 4: Display GitHub Secrets
Write-Host ""
Write-Host "[4/4] GitHub Secrets Setup" -ForegroundColor Green
Write-Host ""
Write-Host "===== GITHUB SECRETS =====" -ForegroundColor Cyan
Write-Host ""

Write-Host "SECRET 1: AZURE_CREDENTIALS" -ForegroundColor Yellow
Write-Host "-------"
Write-Host $spJson
Write-Host ""

Write-Host "SECRET 2: STORAGE_ACCOUNT" -ForegroundColor Yellow
Write-Host "-------"
Write-Host $storageAccount
Write-Host ""

Write-Host "SECRET 3: RESOURCE_GROUP" -ForegroundColor Yellow
Write-Host "-------"
Write-Host $resourceGroup
Write-Host ""

Write-Host "===== NEXT STEPS =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go to GitHub Secrets page:"
Write-Host "   https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions"
Write-Host ""
Write-Host "2. Add 3 secrets (click 'New repository secret'):"
Write-Host "   - Name: AZURE_CREDENTIALS | Value: [paste JSON from SECRET 1 above]"
Write-Host "   - Name: STORAGE_ACCOUNT | Value: [paste SECRET 2 above]"  
Write-Host "   - Name: RESOURCE_GROUP | Value: [paste SECRET 3 above]"
Write-Host ""
Write-Host "3. Push your code:"
Write-Host "   git add . && git commit -m 'fix: add github secrets' && git push"
Write-Host ""
Write-Host "4. Watch deployment at:"
Write-Host "   https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions"
Write-Host ""
Write-Host "5. Visit your website:"
Write-Host "   https://nbaoraclestats.z7.web.core.windows.net/"
Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
