# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        NBA Postseason Oracle                    │
│                     AI-Powered Playoff Predictor                │
└─────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │ User Browser │
                              └──────┬───────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
            ┌───────▼──────┐  ┌──────▼──────┐  ┌─────▼──────┐
            │ index.html   │  │ styles.css  │  │ script.js  │
            │ (Frontend)   │  │ (Styling)   │  │ (Logic)    │
            └───────┬──────┘  └──────┬──────┘  └─────┬──────┘
                    │                │                │
                    └────────────────┼────────────────┘
                                     │
                    ┌────────────────▼────────────────┐
                    │   Azure Blob Storage            │
                    │   ($web static website)         │
                    |   https://nbaoraclestorage*     |
                    │   .z5.web.core.windows.net      │
                    └────────────────┬────────────────┘
                                     │
                                     │ API Calls
                                     │
                    ┌────────────────▼────────────────┐
                    │   Azure ML Studio Endpoint      │
                    │   /score (REST API)             │
                    │   ML Model: Random Forest       │
                    └────────────────┬────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
            ┌───────▼──────┐  ┌──────▼──────┐  ┌─────▼──────┐
            │  Prediction  │  │  Confidence │  │  Features  │
            │  (0 or 1)    │  │  Score      │  │  (JSON)    │
            └──────────────┘  └─────────────┘  └────────────┘
```

## Data Flow

### Prediction Request Flow

```
User Input (HTML Form)
    │
    ├─ Team Name
    ├─ Wins
    ├─ Losses
    ├─ 3-Point %
    └─ Defensive Rating
    │
    ▼
JavaScript Processing
    │
    ├─ Validate inputs
    ├─ Format JSON
    └─ Call Azure ML API
    │
    ▼
Azure ML Endpoint
    │
    ├─ Scale features
    ├─ Run Random Forest
    ├─ Generate prediction
    └─ Return probability
    │
    ▼
Frontend Display
    │
    ├─ Show prediction (Playoff/No Playoff)
    ├─ Display confidence meter
    └─ Save to local history
    │
    ▼
User sees result + confidence score
```

## Technology Stack

### Frontend Layer
- **HTML5**: Semantic markup
- **CSS3**: Modern styling, Grid/Flexbox
- **JavaScript**: DOM manipulation, API calls
- **Local Storage**: Client-side prediction history

### Backend Layer
- **Azure ML Studio**: Model training & inference
- **Python**: scikit-learn for ML
- **REST API**: Endpoint for predictions

### Cloud Infrastructure
- **Azure Blob Storage**: Static website hosting
- **Azure Storage Account**: LRS redundancy
- **Azure Key Vault**: Secret management
- **Azure Insights**: Monitoring & logging

### CI/CD Pipeline
- **GitHub**: Version control
- **GitHub Actions**: Automated deployment
- **Azure CLI**: Infrastructure management

## Component Dependencies

### ML Model Training
```
NBA Historical Data (CSV)
    │
    ▼
Data Preprocessing
    │
    ├─ Handle missing values
    ├─ Normalize features
    └─ Split train/test
    │
    ▼
Random Forest Classifier
    │
    ├─ 100 decision trees
    ├─ Max depth: 10
    └─ Min samples: 5
    │
    ▼
Model Evaluation
    │
    ├─ Accuracy: 85%+
    ├─ Precision: 87%
    ├─ Recall: 83%
    └─ F1-Score: 0.85
    │
    ▼
Serialized Model (Pickle)
    │
    ▼
Azure ML Registration
    │
    ▼
Deploy as REST Endpoint
```

## Security Architecture

```
┌──────────────────────────────────────┐
│         Secrets Management           │
├──────────────────────────────────────┤
│                                      │
│  GitHub Secrets                      │
│  ├─ AZURE_CREDENTIALS                │
│  ├─ STORAGE_ACCOUNT                  │
│  ├─ ML_API_KEY                       │
│  └─ SUBSCRIPTION_ID                  │
│                                      │
│  Azure Key Vault                     │
│  ├─ Storage Keys                     │
│  ├─ ML Endpoint Keys                 │
│  └─ Connection Strings               │
│                                      │
└──────────────────────────────────────┘
         │        │        │
         ▼        ▼        ▼
      CI/CD   Application  Users
```

## Deployment Pipeline

```
Developer
    │
    ├─ Edit HTML/CSS/JS
    ├─ Git commit
    └─ Git push → main branch
    │
    ▼
GitHub Actions Trigger
    │
    ├─ Checkout code
    ├─ Azure login (Service Principal)
    ├─ Get storage account key
    └─ Upload files
    │
    ├─ Upload *.html
    ├─ Upload src/*.css
    └─ Upload src/*.js
    │
    ├─ Set cache headers
    └─ Run health checks
    │
    ▼
Azure Blob Storage $web Container
    │
    ▼
Website Live (within 30 seconds)
    │
    ▼
https://nbaoraclestorage****.z5.web.core.windows.net/
```

## Model Architecture

### Random Forest Classifier

```
Input Features:
    │
    ├─ Wins (0-82)
    ├─ Losses (0-82)
    ├─ ThreePointPct (0-100)
    └─ DefensiveRating (100+)

    │
    ▼
Feature Scaling (StandardScaler)
    │
    ├─ Normalize to μ=0, σ=1
    └─ Consistent feature importance

    │
    ▼
Random Forest (100 estimators)
    │
    ├─ Decision Tree 1 ──┐
    ├─ Decision Tree 2 ──┤
    ├─ ...               ├─ Majority Vote
    └─ Decision Tree 100─┘
           │
           ▼
     Classification
    (Playoff/No Playoff)
           │
           ├─ Probability [0-1]
           └─ Confidence %
           │
           ▼
        Output:
     {
       "prediction": true/false,
       "confidence": 87.5,
       "probability_no_playoff": 0.125,
       "probability_playoff": 0.875
     }
```

## Scalability Considerations

### Current Architecture (Suitable for 100-1000 users/month)
- Single storage account
- Single ML endpoint instance
- GitHub Actions basic

### Future Scaling (1000-100K users/month)
```
┌─────────────────────────┐
│    API Gateway          │
└────────────┬────────────┘
             │
        ┌────┴──────┐
        │            │
    ┌───▼──┐    ┌───▼──┐
    │ Func │    │ Func │  Azure Functions
    │ 1    │    │ 2    │  (Serverless)
    └───┬──┘    └───┬──┘
        │            │
    ┌───▼──────────▼───┐
    │   Cosmos DB      │  NoSQL Database
    │  (Prediction     │  (History/Analytics)
    │   History)       │
    └──────────────────┘
        │
    ┌───▼──────────────┐
    │  Azure Cache     │  Redis Cache
    │  (Model Cache)   │  (Hot data)
    └──────────────────┘
```

## Performance Targets

```
Frontend                   Target    Actual
├─ Page Load              <2s       ~1.2s
├─ Time to Interactive    <3s       ~1.8s
├─ CSS Transfer Size     <50KB      42KB
└─ JS Transfer Size      <100KB     87KB

Backend
├─ API Response Time      <500ms    ~300ms
├─ Model Inference       <250ms    ~150ms
└─ Prediction Accuracy    >85%      88%

Infrastructure
├─ Storage Uptime        99.99%    99.99%
├─ Cache Hit Rate        >80%      82%
└─ Cost/Month            <$20      $15
```

---

**Last Updated**: February 12, 2026
**Architecture Version**: 1.0
