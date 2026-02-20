#!/usr/bin/env pwsh
<#
.SYNOPSIS
Direct upload script to deploy NBA Oracle to Azure Storage (bypasses GitHub Actions)
.DESCRIPTION
This script uploads all necessary files directly to your Azure Storage account
.EXAMPLE
.\deploy-direct.ps1 -StorageAccount "nbaoraclestats" -ResourceGroup "nba-finals"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccount,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [string]$Container = '$web'
)

# Colors for output
$colors = @{
    Success = 'Green'
    Error = 'Red'
    Warning = 'Yellow'
    Info = 'Cyan'
}

function Write-Status {
    param([string]$Message, [string]$Status = 'Info')
    $color = $colors[$Status] ?? 'White'
    Write-Host $Message -ForegroundColor $color
}

# Check if logged in to Azure
Write-Status "🔐 Checking Azure authentication..." Info
try {
    $account = az account show --query "name" -o tsv
    Write-Status "✅ Logged in as: $account" Success
} catch {
    Write-Status "❌ Not logged in to Azure. Run: az login" Error
    exit 1
}

# Verify storage account exists
Write-Status "📦 Verifying storage account: $StorageAccount" Info
try {
    $storage = az storage account show `
        --name $StorageAccount `
        --resource-group $ResourceGroup `
        --query "id" -o tsv
    Write-Status "✅ Storage account found: $storage" Success
} catch {
    Write-Status "❌ Storage account not found. Check name and resource group." Error
    exit 1
}

# Get storage account key
Write-Status "🔑 Getting storage account key..." Info
try {
    $key = az storage account keys list `
        --account-name $StorageAccount `
        --resource-group $ResourceGroup `
        --query "[0].value" -o tsv
    if (-not $key) { throw "No key returned" }
    Write-Status "✅ Storage account key retrieved" Success
} catch {
    Write-Status "❌ Failed to get storage account key" Error
    exit 1
}

# Files to upload
$filesToUpload = @(
    'index.html',
    'README.md',
    'PREDICTIONS_READY.md',
    'ML_PREDICTOR_SETUP.md',
    'src/script.js',
    'src/predictor.js',
    'src/styles.css',
    'ml/fixed_regular_season_data.csv'
)

Write-Status "📤 Starting file upload..." Info
$uploadedCount = 0
$failedCount = 0

foreach ($file in $filesToUpload) {
    if (Test-Path $file) {
        Write-Host "  Uploading: $file" -ForegroundColor Gray
        try {
            az storage blob upload `
                --account-name $StorageAccount `
                --account-key $key `
                --container-name $Container `
                --name $file `
                --file $file `
                --overwrite | Out-Null
            Write-Status "    ✅ $file" Success
            $uploadedCount++
        } catch {
            Write-Status "    ❌ $file failed: $_" Error
            $failedCount++
        }
    } else {
        Write-Status "    ⚠️  $file not found (skipping)" Warning
    }
}

# Summary
Write-Host ""
Write-Status "📊 Upload Summary:" Info
Write-Status "  Uploaded: $uploadedCount files" Success
if ($failedCount -gt 0) {
    Write-Status "  Failed: $failedCount files" Error
}

# Get and display the website URL
Write-Status "🌐 Getting website URL..." Info
try {
    $endpoint = az storage account show `
        --name $StorageAccount `
        --resource-group $ResourceGroup `
        --query "primaryEndpoints.web" -o tsv
    Write-Status "✅ Website is live at:" Success
    Write-Host "   $endpoint" -ForegroundColor Cyan
} catch {
    Write-Status "⚠️  Could not determine website URL" Warning
}

Write-Host ""
Write-Status "🎉 Deployment complete!" Success
Write-Status "Visit your site and refresh (Ctrl+F5) to see changes" Info
