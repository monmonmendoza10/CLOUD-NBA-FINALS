param([switch]$SkipLogin)

# Update PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "`n=== NBA Oracle GitHub Actions Setup ===" -ForegroundColor Cyan

# Configuration
$servicePrincipalName = "github-actions-nba-oracle"
$subscriptionId = "2ee61742-e4b7-4e3a-90c9-11d13557d797"
$storageAccount = "nbaoraclestats"
$resourceGroup = "nba-finals"

Write-Host "Configuration:" -ForegroundColor Gray
Write-Host "- Service Principal: $servicePrincipalName"
Write-Host "- Subscription: $subscriptionId"
Write-Host "- Storage: $storageAccount"
Write-Host "- Resource Group: $resourceGroup"
Write-Host ""

if (-not $SkipLogin) {
    Write-Host "[1] Logging in to Azure..." -ForegroundColor Cyan
    Write-Host "Browser will open - enter the device code shown below" -ForegroundColor Yellow
    Write-Host ""
    
    az login --use-device-code
}

Write-Host "`n[2] Creating service principal..." -ForegroundColor Cyan

try {
    # Remove if exists
    $existing = az ad sp list --display-name $servicePrincipalName --query "[0].id" -o tsv 2>$null
    if ($existing) {
        Write-Host "Removing existing service principal..."
        az ad sp delete --id $existing 2>$null
    }
    
    # Create new
    Write-Host "Creating $servicePrincipalName..."
    $credentials = az ad sp create-for-rbac `
        --name $servicePrincipalName `
        --role "Contributor" `
        --scopes "/subscriptions/$subscriptionId" `
        --sdk-auth | ConvertFrom-Json
    
    Write-Host "Success!" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== GITHUB SECRETS ===" -ForegroundColor Yellow
Write-Host "Add these 3 secrets to GitHub:" -ForegroundColor White
Write-Host "https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions" -ForegroundColor Cyan
Write-Host ""

Write-Host "--- SECRET 1: AZURE_CREDENTIALS ---" -ForegroundColor Yellow
$creds_json = $credentials | ConvertTo-Json -Compress
Write-Host $creds_json -ForegroundColor White
Write-Host ""

Write-Host "--- SECRET 2: STORAGE_ACCOUNT ---" -ForegroundColor Yellow
Write-Host $storageAccount -ForegroundColor White
Write-Host ""

Write-Host "--- SECRET 3: RESOURCE_GROUP ---" -ForegroundColor Yellow
Write-Host $resourceGroup -ForegroundColor White
Write-Host ""

Write-Host "=== NEXT STEPS ===" -ForegroundColor Green
Write-Host "1. Copy the secrets above to GitHub" -ForegroundColor Gray
Write-Host "2. Go to: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions" -ForegroundColor Gray
Write-Host "3. Click 'New repository secret' for each one" -ForegroundColor Gray
Write-Host "4. Name: AZURE_CREDENTIALS, Value: [paste JSON above]" -ForegroundColor Gray
Write-Host "5. Name: STORAGE_ACCOUNT, Value: $storageAccount" -ForegroundColor Gray
Write-Host "6. Name: RESOURCE_GROUP, Value: $resourceGroup" -ForegroundColor Gray
Write-Host ""
Write-Host "Then push your code and GitHub Actions will deploy automatically!" -ForegroundColor Cyan
Write-Host ""
