#!/usr/bin/env pwsh
<#
.SYNOPSIS
Complete setup for GitHub Actions deployment with Azure
.DESCRIPTION
Creates Azure Service Principal and configures GitHub Secrets
.NOTES
Requires: Azure CLI and GitHub CLI
#>

param(
    [string]$GitHubUsername = "monmonmendoza10",
    [string]$GitHubRepo = "CLOUD-NBA-FINALS",
    [string]$StorageAccount = "nbaoraclestats",
    [string]$ResourceGroup = "nba-finals"
)

# Colors
$colors = @{
    Success = 'Green'
    Error = 'Red'
    Warning = 'Yellow'
    Info = 'Cyan'
}

function Write-Status {
    param([string]$Message, [string]$Status = 'Info')
    $color = $colors[$Status] ?? 'White'
    Write-Host "[$Status] $Message" -ForegroundColor $color
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Check prerequisites
Write-Host "`n🔧 Checking prerequisites..." -ForegroundColor Cyan
Write-Host "================================="

$hasAzCli = Test-Command "az"
$hasGhCli = Test-Command "gh"

if ($hasAzCli) {
    Write-Status "✅ Azure CLI found" Success
} else {
    Write-Status "❌ Azure CLI not found" Error
    Write-Host ""
    Write-Host "⚠️  Please install Azure CLI first:" -ForegroundColor Yellow
    Write-Host "   https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows"
    Write-Host ""
    exit 1
}

if ($hasGhCli) {
    Write-Status "✅ GitHub CLI found" Success
} else {
    Write-Status "⚠️  GitHub CLI not found (optional but recommended)" Warning
    Write-Host "   Install from: https://cli.github.com/"
}

Write-Host ""
Write-Status "🔐 Step 1: Azure Login" Info
Write-Host "================================="
Write-Host "If browser doesn't open, visit: https://microsoft.com/devicelogin" -ForegroundColor Gray

try {
    az login
    Write-Status "✅ Logged in to Azure" Success
} catch {
    Write-Status "❌ Azure login failed" Error
    exit 1
}

Write-Host ""
Write-Status "📊 Step 2: Get Subscription Details" Info
Write-Host "================================="

try {
    $subInfo = az account show --query "{subscriptionId:id, displayName:name}" -o json | ConvertFrom-Json
    Write-Status "✅ Subscription: $($subInfo.displayName)" Success
    Write-Status "   ID: $($subInfo.subscriptionId)" Info
    $subscriptionId = $subInfo.subscriptionId
} catch {
    Write-Status "❌ Failed to get subscription info" Error
    exit 1
}

Write-Host ""
Write-Status "🤖 Step 3: Create Service Principal" Info
Write-Host "================================="
Write-Host "Creating: github-actions-nba-oracle..." -ForegroundColor Gray

try {
    # Delete existing if it exists
    $existingSp = az ad sp list --display-name "github-actions-nba-oracle" --query "[0].id" -o tsv 2>$null
    if ($existingSp) {
        Write-Host "Removing existing service principal..." -ForegroundColor Gray
        az ad sp delete --id $existingSp
    }
    
    # Create new service principal
    $sp = az ad sp create-for-rbac `
        --name "github-actions-nba-oracle" `
        --role "Contributor" `
        --scopes "/subscriptions/$subscriptionId" `
        --sdk-auth | ConvertFrom-Json
    
    Write-Status "✅ Service Principal Created" Success
    Write-Status "   Name: github-actions-nba-oracle" Info
    Write-Status "   Client ID: $($sp.clientId)" Info
} catch {
    Write-Status "❌ Failed to create service principal" Error
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Status "📋 Step 4: Service Principal Details" Info
Write-Host "================================="
Write-Host "Copy this JSON - you'll need it next:" -ForegroundColor Yellow
Write-Host ""
$jsonOutput = $sp | ConvertTo-Json -Depth 10
Write-Host $jsonOutput -ForegroundColor Cyan
Write-Host ""

# Save to file
$jsonOutput | Out-File "azure-credentials.json" -Encoding UTF8
Write-Status "✅ Saved to: azure-credentials.json" Success

Write-Host ""
Write-Status "🔑 Step 5: Configure GitHub Secrets" Info
Write-Host "================================="

if ($hasGhCli) {
    Write-Host "Configuring GitHub secrets with CLI..." -ForegroundColor Gray
    
    try {
        # Convert to JSON string for secret storage
        $credsJson = $sp | ConvertTo-Json -Compress
        
        # Set secrets
        gh secret set AZURE_CREDENTIALS --body $credsJson --repo "$GitHubUsername/$GitHubRepo"
        Write-Status "✅ AZURE_CREDENTIALS set" Success
        
        gh secret set STORAGE_ACCOUNT --body $StorageAccount --repo "$GitHubUsername/$GitHubRepo"
        Write-Status "✅ STORAGE_ACCOUNT set" Success
        
        gh secret set RESOURCE_GROUP --body $ResourceGroup --repo "$GitHubUsername/$GitHubRepo"
        Write-Status "✅ RESOURCE_GROUP set" Success
        
    } catch {
        Write-Status "⚠️  Failed to set GitHub secrets with CLI" Warning
        Write-Host "You'll need to add them manually via GitHub web interface" -ForegroundColor Yellow
    }
} else {
    Write-Status "⚠️  GitHub CLI not available - manual setup required" Warning
}

Write-Host ""
Write-Status "📋 Manual GitHub Secret Setup" Info
Write-Host "================================="

if (-not $hasGhCli) {
    Write-Host "Follow these steps to add secrets manually:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "1. Go to GitHub Secrets:" -ForegroundColor White
    Write-Host "   https://github.com/$GitHubUsername/$GitHubRepo/settings/secrets/actions"
    Write-Host ""
    Write-Host "2. Click 'New repository secret'" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Create secrets with these values:" -ForegroundColor White
    Write-Host ""
    Write-Host "   Secret 1:" -ForegroundColor Cyan
    Write-Host "   Name:  AZURE_CREDENTIALS" -ForegroundColor Yellow
    Write-Host "   Value: (paste the JSON above)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Secret 2:" -ForegroundColor Cyan
    Write-Host "   Name:  STORAGE_ACCOUNT" -ForegroundColor Yellow
    Write-Host "   Value: $StorageAccount" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Secret 3:" -ForegroundColor Cyan
    Write-Host "   Name:  RESOURCE_GROUP" -ForegroundColor Yellow
    Write-Host "   Value: $ResourceGroup" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Status "🚀 Step 6: Trigger Deployment" Info
Write-Host "================================="

Write-Host "Make a test commit to trigger GitHub Actions:" -ForegroundColor Gray
Write-Host ""
Write-Host "  cd d:\cldcpm\CLOUD-NBA-FINALS" -ForegroundColor Cyan
Write-Host "  git add ." -ForegroundColor Cyan
Write-Host "  git commit -m 'fix: enable azure deployment with secrets'" -ForegroundColor Cyan
Write-Host "  git push origin main" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then watch the deployment:" -ForegroundColor Gray
Write-Host "  https://github.com/$GitHubUsername/$GitHubRepo/actions" -ForegroundColor Cyan
Write-Host ""

Write-Host ""
Write-Status "✨ Setup Complete!" Success
Write-Host "================================="
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Add GitHub secrets (manual or CLI)" -ForegroundColor Gray
Write-Host "2. Push a test commit"  -ForegroundColor Gray
Write-Host "3. Watch GitHub Actions deploy" -ForegroundColor Gray
Write-Host "4. Visit your deployed website" -ForegroundColor Gray
Write-Host ""
Write-Host "Website URL (after deployment):" -ForegroundColor Cyan
Write-Host "https://nbaoraclestats.z7.web.core.windows.net/" -ForegroundColor White
Write-Host ""
