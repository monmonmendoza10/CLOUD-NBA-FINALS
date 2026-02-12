# PHASE 3: Machine Learning Model Training & Deployment

## 🎯 Objective
Train an ML model on NBA data and deploy it as a REST endpoint.

## 📋 Prerequisites
- Azure ML Workspace created (Phase 2)
- Python 3.8+
- sklearn, pandas, numpy installed
- Historical NBA dataset (CSV)

## 🚀 Steps

### 1. Prepare Your Dataset

**Expected CSV Format:**
```csv
Team,Wins,Losses,ThreePointPct,DefensiveRating,MadePlayoffs
Boston Celtics,58,24,38.2,110.5,1
Miami Heat,46,36,35.8,112.3,1
...
```

**Data Sources:**
- [NBA Stats](https://www.stats.nba.com/)
- [Basketball Reference](https://www.basketball-reference.com/)
- Sample data in `ml/sample_data.csv`

### 2. Install Dependencies

```bash
pip install azure-ai-ml azure-identity scikit-learn pandas numpy joblib
```

### 3. Train the Model Locally

```bash
# Navigate to project directory
cd ml

# Run training script
python train_model.py
```

**Output:**
- Model saved: `ml/models/nba_playoff_model.pkl`
- Scaler saved: `ml/models/scaler.pkl`
- Metrics: Accuracy, precision, recall, F1-score

### 4. Set Azure Credentials

```bash
# Login to Azure
az login

# Set default subscription
az account set --subscription "your-subscription-id"

# Set environment variables
$env:AZURE_SUBSCRIPTION_ID = "your-subscription-id"
$env:AZURE_RESOURCE_GROUP = "nba-oracle-rg"
$env:AZURE_ML_WORKSPACE = "nba-oracle-ml"
```

### 5. Deploy to Azure ML

```bash
# Run deployment script
python ml/deploy_model.py
```

**This will:**
1. Register the model in Azure ML Studio
2. Create a managed online endpoint
3. Deploy the model
4. Test the endpoint
5. Save configuration to `.env.deployment`

### 6. Upload Training Data to Azure ML

```bash
# Create dataset in Azure ML
az ml data create \
  --file ml/sample_data.csv \
  --name nba-playoffs-data \
  --type uri_folder

# Or use Azure ML Studio UI:
# 1. Go to Azure ML Studio
# 2. Select "Data" → "Create"
# 3. Upload sample_data.csv
```

### 7. Use the Endpoint

**Get Endpoint URL & Key:**
```bash
az ml online-endpoint show \
  --name nba-oracle-endpoint \
  --query "scoring_uri"
```

**Make Predictions (Python):**
```python
import requests
import json

endpoint_uri = "https://your-endpoint.inference.ml.azure.com/score"
api_key = "your-api-key"

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}"
}

data = {
    "data": [
        {
            "Wins": 55,
            "Losses": 27,
            "ThreePointPct": 38.5,
            "DefensiveRating": 110.2
        }
    ]
}

response = requests.post(endpoint_uri, json=data, headers=headers)
print(response.json())
```

**Make Predictions (JavaScript):**
```javascript
async function callAzureMLEndpoint(teamData) {
    const endpoint = "https://your-endpoint.inference.ml.azure.com/score";
    const apiKey = process.env.ML_API_KEY;
    
    const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({
            data: [{
                Wins: teamData.wins,
                Losses: teamData.losses,
                ThreePointPct: teamData.threePct,
                DefensiveRating: teamData.defRating
            }]
        })
    });
    
    return await response.json();
}
```

### 8. Monitor Model Performance

```bash
# Get endpoint metrics
az ml online-endpoint get-logs \
  --name nba-oracle-endpoint \
  --lines 50

# Check deployment status
az ml online-deployment get-logs \
  --name playoff-deploy \
  --endpoint-name nba-oracle-endpoint
```

## 📊 Model Explanation

### Features Used:
- **Wins**: Team wins in season
- **Losses**: Team losses in season
- **ThreePointPct**: Team 3-point percentage
- **DefensiveRating**: Points allowed per 100 possessions

### Algorithm: Random Forest
- 100 decision trees
- Max depth: 10
- Min samples split: 5
- Prevents overfitting

### Expected Accuracy:
- Training: 92-95%
- Test: 85-88%
- Real-world: 80-85% (variables change year to year)

## 🔄 Retraining Pipeline

```bash
# Schedule monthly retraining
# 1. Fetch latest NBA stats
# 2. Update sample_data.csv
# 3. Run python train_model.py
# 4. Deploy new version
# 5. Update endpoint to new model
```

## ⚠️ Common Issues

**Issue**: "Model not found"
```bash
# Solution: Ensure model file exists
ls ml/models/nba_playoff_model.pkl
```

**Issue**: "Endpoint authentication failed"
```bash
# Solution: Get fresh API key
az ml online-endpoint get-credentials \
  --name nba-oracle-endpoint
```

**Issue**: "Low accuracy"
```bash
# Solution: Improve data quality
# - Add more training samples
# - Include more seasons
# - Engineer new features
```

## Next Phase
→ Move to [PHASE4-CICD-SETUP.md](PHASE4-CICD-SETUP.md) for CI/CD automation
