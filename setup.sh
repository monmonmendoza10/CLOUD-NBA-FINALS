#!/bin/bash
# NBA Oracle Quick Start Setup Script

echo "🏀 NBA Postseason Oracle - Quick Setup"
echo "========================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
check_tools() {
    echo -e "\n${YELLOW}Checking prerequisites...${NC}"
    
    tools=("git" "az" "python" "pip")
    
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            echo -e "${GREEN}✓${NC} $tool installed"
        else
            echo -e "${RED}✗${NC} $tool not found. Please install it."
            exit 1
        fi
    done
}

# Setup Python environment
setup_python() {
    echo -e "\n${YELLOW}Setting up Python environment...${NC}"
    
    # Create virtual environment
    python -m venv venv
    
    # Activate venv
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        source venv/Scripts/activate
    else
        source venv/bin/activate
    fi
    
    # Install dependencies
    pip install --upgrade pip
    pip install -r requirements.txt
    
    echo -e "${GREEN}✓${NC} Python environment ready"
}

# Setup Azure
setup_azure() {
    echo -e "\n${YELLOW}Setting up Azure configuration...${NC}"
    
    # Login to Azure
    az login
    
    # Set subscription
    read -p "Enter your Azure Subscription ID: " subscription_id
    az account set --subscription $subscription_id
    
    # Create .env file
    cat > .env << EOF
# Azure Configuration
AZURE_SUBSCRIPTION_ID=$subscription_id
AZURE_RESOURCE_GROUP=nba-oracle-rg
AZURE_STORAGE_ACCOUNT=nbaoraclestorage
AZURE_ML_WORKSPACE=nba-oracle-ml
AZURE_ML_REGION=eastus

# Add these after Phase 2:
# ML_MODEL_ENDPOINT=
# ML_API_KEY=
EOF
    
    echo -e "${GREEN}✓${NC} .env file created (add values as needed)"
}

# Setup Git
setup_git() {
    echo -e "\n${YELLOW}Setting up Git repository...${NC}"
    
    if [ ! -d ".git" ]; then
        git init
        git add .
        git commit -m "Initial commit: NBA Oracle"
        
        read -p "Enter your GitHub repo URL: " repo_url
        git remote add origin $repo_url
        git branch -M main
        
        echo -e "${YELLOW}Ready to push with: git push -u origin main${NC}"
    else
        echo -e "${GREEN}✓${NC} Git repository already initialized"
    fi
}

# Print next steps
print_next_steps() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Setup Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    echo -e "\n${YELLOW}Next Steps:${NC}"
    echo "1. Phase 1 (UI): Already complete! ✅"
    echo "   - Website is ready to test locally"
    echo "   - Run: npx http-server . -p 8000"
    echo ""
    echo "2. Phase 2 (Azure):"
    echo "   - Follow: docs/PHASE2-AZURE-SETUP.md"
    echo "   - Create storage account"
    echo "   - Deploy files"
    echo ""
    echo "3. Phase 3 (ML):"
    echo "   - Follow: docs/PHASE3-ML-SETUP.md"
    echo "   - Train model: python ml/train_model.py"
    echo "   - Deploy: python ml/deploy_model.py"
    echo ""
    echo "4. Phase 4 (CI/CD):"
    echo "   - Follow: docs/PHASE4-CICD-SETUP.md"
    echo "   - Add GitHub secrets"
    echo "   - Push code"
    echo ""
    echo -e "${YELLOW}📚 Full docs at:${NC}"
    echo "   - docs/README.md"
    echo "   - docs/PHASE2-AZURE-SETUP.md"
    echo "   - docs/PHASE3-ML-SETUP.md"
    echo "   - docs/PHASE4-CICD-SETUP.md"
}

# Main execution
main() {
    check_tools
    setup_python
    
    read -p "Setup Azure? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_azure
    fi
    
    read -p "Setup Git repository? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_git
    fi
    
    print_next_steps
}

main
