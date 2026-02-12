"""
NBA Playoff Prediction Model Training Script
Trains a classification model to predict if teams make the playoffs
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import joblib
import os

# Sample NBA data for demonstration
SAMPLE_DATA = """Team,Wins,Losses,ThreePointPct,DefensiveRating,MadePlayoffs
Boston Celtics,58,24,38.2,110.5,1
Miami Heat,46,36,35.8,112.3,1
Philadelphia 76ers,52,30,37.1,111.2,1
New York Knicks,50,32,36.5,113.1,1
Toronto Raptors,44,38,34.9,114.2,1
Denver Nuggets,56,26,38.5,109.8,1
Los Angeles Lakers,54,28,37.2,110.4,1
Golden State Warriors,51,31,39.1,111.6,1
Phoenix Suns,49,33,36.8,112.9,1
Dallas Mavericks,48,34,36.2,113.5,1
Orlando Magic,47,35,35.1,112.1,1
Sacramento Kings,46,36,38.9,115.3,0
Milwaukee Bucks,45,37,37.4,113.8,1
Atlanta Hawks,41,41,35.6,116.2,0
Chicago Bulls,39,43,34.8,117.1,0
Cleveland Cavaliers,38,44,33.9,118.5,0
Washington Wizards,37,45,33.2,119.3,0
Detroit Pistons,35,47,32.1,120.8,0
Charlotte Hornets,33,49,31.5,122.1,0
New Orleans Pelicans,32,50,30.8,123.4,0
"""

def load_data(csv_path=None):
    """Load NBA team statistics."""
    if csv_path and os.path.exists(csv_path):
        print(f"Loading data from {csv_path}")
        return pd.read_csv(csv_path)
    else:
        print("Using sample NBA data for demonstration")
        from io import StringIO
        return pd.read_csv(StringIO(SAMPLE_DATA))

def prepare_data(df):
    """Prepare data for model training."""
    # Define features and target
    X = df[['Wins', 'Losses', 'ThreePointPct', 'DefensiveRating']]
    y = df['MadePlayoffs']
    
    # Handle missing values
    X = X.fillna(X.mean())
    
    # Scale features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    return X_scaled, y, scaler

def train_model(X, y):
    """Train Random Forest classifier."""
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train model
    print("Training Random Forest classifier...")
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        min_samples_split=5,
        min_samples_leaf=2,
        random_state=42,
        n_jobs=-1
    )
    
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n✅ Model Accuracy: {accuracy:.2%}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=['No Playoff', 'Playoff']))
    
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # Feature importance
    feature_names = ['Wins', 'Losses', 'ThreePointPct', 'DefensiveRating']
    importances = model.feature_importances_
    
    print("\nFeature Importance:")
    for name, importance in zip(feature_names, importances):
        print(f"  {name}: {importance:.4f}")
    
    return model, X_test, y_test

def save_model(model, scaler, output_dir='ml/models'):
    """Save trained model and scaler."""
    os.makedirs(output_dir, exist_ok=True)
    
    model_path = os.path.join(output_dir, 'nba_playoff_model.pkl')
    scaler_path = os.path.join(output_dir, 'scaler.pkl')
    
    joblib.dump(model, model_path)
    joblib.dump(scaler, scaler_path)
    
    print(f"\n✅ Model saved to {model_path}")
    print(f"✅ Scaler saved to {scaler_path}")
    
    return model_path, scaler_path

def make_prediction(model, scaler, wins, losses, three_pct, def_rating):
    """Make a prediction for a team."""
    input_data = np.array([[wins, losses, three_pct, def_rating]])
    input_scaled = scaler.transform(input_data)
    
    prediction = model.predict(input_scaled)[0]
    probability = model.predict_proba(input_scaled)[0]
    
    return {
        'will_make_playoffs': bool(prediction),
        'no_playoff_prob': float(probability[0]),
        'playoff_prob': float(probability[1]),
        'confidence': float(max(probability)) * 100
    }

def main():
    """Main training pipeline."""
    print("=" * 60)
    print("🏀 NBA Playoff Prediction Model Training")
    print("=" * 60)
    
    # Load data
    df = load_data()
    print(f"\nLoaded {len(df)} team records")
    print(df.head())
    
    # Prepare data
    X, y, scaler = prepare_data(df)
    print(f"\nFeatures shape: {X.shape}")
    print(f"Target distribution:\n{y.value_counts()}")
    
    # Train model
    model, X_test, y_test = train_model(X, y)
    
    # Save model
    save_model(model, scaler)
    
    # Test predictions
    print("\n" + "=" * 60)
    print("📊 Sample Predictions:")
    print("=" * 60)
    
    test_cases = [
        {"name": "Strong Team", "wins": 55, "losses": 27, "3pct": 38.5, "defr": 110.2},
        {"name": "Middle Team", "wins": 45, "losses": 37, "3pct": 35.8, "defr": 115.1},
        {"name": "Weak Team", "wins": 30, "losses": 52, "3pct": 32.1, "defr": 121.5},
    ]
    
    for case in test_cases:
        result = make_prediction(
            model, scaler,
            case["wins"], case["losses"],
            case["3pct"], case["defr"]
        )
        status = "✅ PLAYOFF" if result['will_make_playoffs'] else "❌ NO PLAYOFF"
        print(f"\n{case['name']}:")
        print(f"  Record: {case['wins']}W - {case['losses']}L")
        print(f"  3P%: {case['3pct']}% | Def Rating: {case['defr']}")
        print(f"  Prediction: {status}")
        print(f"  Confidence: {result['confidence']:.1f}%")
    
    print("\n" + "=" * 60)
    print("✅ Training Complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()
