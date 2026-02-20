"""
NBA Playoff Prediction Model - Training with Real Data
Trains a Random Forest classifier using the provided CSV data
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import joblib
import os
import json

def load_data(csv_path):
    """Load NBA team statistics."""
    print(f"\n📊 Loading data from {csv_path}")
    df = pd.read_csv(csv_path)
    print(f"✅ Loaded {len(df)} records")
    return df

def prepare_data(df):
    """Prepare data for model training."""
    print("\n🔧 Preparing data...")
    
    # Feature columns
    feature_cols = ['Wins', 'Losses', 'ThreePointPct', 'DefensiveRating']
    X = df[feature_cols].copy()
    y = df['MadePlayoffs'].copy()
    
    print(f"Features: {feature_cols}")
    print(f"Target: MadePlayoffs (1=Yes, 0=No)")
    print(f"Dataset size: {len(X)} samples")
    print(f"Playoff teams: {y.sum()} | Non-playoff: {len(y) - y.sum()}")
    
    return X, y, feature_cols

def train_model(X, y):
    """Train the Random Forest classifier."""
    print("\n🤖 Training models...")
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Training set: {len(X_train)} samples")
    print(f"Test set: {len(X_test)} samples")
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Random Forest model
    print("\n  Training Random Forest...")
    rf_model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    rf_model.fit(X_train_scaled, y_train)
    
    # Gradient Boosting model
    print("  Training Gradient Boosting...")
    gb_model = GradientBoostingClassifier(
        n_estimators=100,
        max_depth=5,
        random_state=42
    )
    gb_model.fit(X_train_scaled, y_train)
    
    # Evaluate Random Forest
    print("\n📊 Random Forest Results:")
    rf_pred = rf_model.predict(X_test_scaled)
    rf_accuracy = accuracy_score(y_test, rf_pred)
    print(f"Accuracy: {rf_accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, rf_pred, 
          target_names=['Non-Playoff', 'Playoff']))
    
    # Evaluate Gradient Boosting
    print("\n📊 Gradient Boosting Results:")
    gb_pred = gb_model.predict(X_test_scaled)
    gb_accuracy = accuracy_score(y_test, gb_pred)
    print(f"Accuracy: {gb_accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, gb_pred, 
          target_names=['Non-Playoff', 'Playoff']))
    
    # Use the better model
    if rf_accuracy >= gb_accuracy:
        print(f"\n✅ Using Random Forest (Accuracy: {rf_accuracy:.4f})")
        best_model = rf_model
    else:
        print(f"\n✅ Using Gradient Boosting (Accuracy: {gb_accuracy:.4f})")
        best_model = gb_model
    
    return best_model, scaler, {
        'rf_accuracy': rf_accuracy,
        'gb_accuracy': gb_accuracy
    }

def save_model(model, scaler, metrics, output_dir='ml/models'):
    """Save model and scaler."""
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"\n💾 Saving model to {output_dir}")
    joblib.dump(model, os.path.join(output_dir, 'nba_playoff_model.pkl'))
    joblib.dump(scaler, os.path.join(output_dir, 'scaler.pkl'))
    
    # Save metrics
    with open(os.path.join(output_dir, 'metrics.json'), 'w') as f:
        json.dump(metrics, f, indent=2)
    
    print("✅ Model saved successfully!")

def main():
    # Load the CSV data
    csv_path = 'ml/fixed_regular_season_data.csv'
    
    # Check if file exists
    if not os.path.exists(csv_path):
        print(f"❌ Error: {csv_path} not found!")
        print("Please ensure the CSV file is in the ml/ directory")
        return
    
    # Load and prepare data
    df = load_data(csv_path)
    X, y, feature_cols = prepare_data(df)
    
    # Train model
    model, scaler, metrics = train_model(X, y)
    
    # Save model
    save_model(model, scaler, metrics)
    
    print("\n" + "="*50)
    print("✨ Training Complete!")
    print("="*50)
    print("Model is ready for predictions!")

if __name__ == '__main__':
    main()
