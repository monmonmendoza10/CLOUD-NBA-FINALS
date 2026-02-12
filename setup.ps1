# NBA Oracle Quick Start Setup Script (PowerShell)

Write-Host "🏀 NBA Postseason Oracle - Quick Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Colors
function Write-OK { Write-Host "✓ $args" -ForegroundColor Green }
function Write-WARN { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Write-ERROR { Write-Host "✗ $args" -ForegroundColor Red }

# Check prerequisites
function Check-Tools {
    Write-WARN "Checking prerequisites..."
    
    $tools = @("git", "az", "python", "pip")
    
    foreach ($tool in $tools) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) {
            Write-OK "$tool installed"
        } else {
            Write-ERROR "$tool not found. Please install it."
            exit 1
        }
    }
}

# Setup Python environment
function Setup-Python {
    Write-WARN "Setting up Python environment..."
    
    # Create virtual environment
    python -m venv venv
    
    # Activate venv
    & .\venv\Scripts\Activate.ps1
    
    # Install dependencies
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    
    Write-OK "Python environment ready"
}

# Setup Azure
function Setup-Azure {
    Write-WARN "Setting up Azure configuration..."
    
    # Login to Azure
    az login
    
    # Set subscription
    $subscriptionId = Read-Host "Enter your Azure Subscription ID"
    az account set --subscription $subscriptionId
    
    # Create .env file
    $envContent = @"
# Azure Configuration
AZURE_SUBSCRIPTION_ID=$subscriptionId
AZURE_RESOURCE_GROUP=nba-oracle-rg
AZURE_STORAGE_ACCOUNT=nbaoraclestorage
AZURE_ML_WORKSPACE=nba-oracle-ml
AZURE_ML_REGION=eastus

# Add these after Phase 2:
# ML_MODEL_ENDPOINT=
# ML_API_KEY=
"@
    
    $envContent | Out-File -FilePath ".env" -Encoding UTF8
    
    Write-OK ".env file created (add values as needed)"
}

# Setup Git
function Setup-Git {
    Write-WARN "Setting up Git repository..."
    
    if (-not (Test-Path ".git")) {
        git init
        git add .
        git commit -m "Initial commit: NBA Oracle"
        
        $repoUrl = Read-Host "Enter your GitHub repo URL"
        git remote add origin $repoUrl
        git branch -M main
        
        Write-WARN "Ready to push with: git push -u origin main"
    } else {
        Write-OK "Git repository already initialized"
    }
}

# Print next steps
function Print-NextSteps {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-OK "Setup Complete!"
    Write-Host "========================================" -ForegroundColor Green
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Phase 1 (UI): Already complete! ✅"
    Write-Host "   - Website is ready to test locally"
    Write-Host "   - Run: npx http-server . -p 8000"
    Write-Host ""
    Write-Host "2. Phase 2 (Azure):"
    Write-Host "   - Follow: docs/PHASE2-AZURE-SETUP.md"
    Write-Host "   - Create storage account"
    Write-Host "   - Deploy files"
    Write-Host ""
    Write-Host "3. Phase 3 (ML):"
    Write-Host "   - Follow: docs/PHASE3-ML-SETUP.md"
    Write-Host "   - Train model: python ml/train_model.py"
    Write-Host "   - Deploy: python ml/deploy_model.py"
    Write-Host ""
    Write-Host "4. Phase 4 (CI/CD):"
    Write-Host "   - Follow: docs/PHASE4-CICD-SETUP.md"
    Write-Host "   - Add GitHub secrets"
    Write-Host "   - Push code"
    Write-Host ""
    Write-Host "📚 Full docs at:" -ForegroundColor Yellow
    Write-Host "   - README.md"
    Write-Host "   - docs/PHASE2-AZURE-SETUP.md"
    Write-Host "   - docs/PHASE3-ML-SETUP.md"
    Write-Host "   - docs/PHASE4-CICD-SETUP.md"
}

# Main execution
function Main {
    Check-Tools
    Setup-Python
    
    $response = Read-Host "Setup Azure? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Setup-Azure
    }
    
    $response = Read-Host "Setup Git repository? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        Setup-Git
    }
    
    Print-NextSteps
}

Main
