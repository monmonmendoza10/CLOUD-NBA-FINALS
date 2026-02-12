"""
Azure ML Model Deployment Script
Registers and deploys the trained model to Azure ML
"""

import os
import json
from azure.ai.ml import MLClient
from azure.ai.ml.entities import Model, ManagedOnlineEndpoint, ManagedOnlineDeployment
from azure.identity import DefaultAzureCredential, AzureCliCredential
from azure.ai.ml.constants import AssetTypes

def get_ml_client(subscription_id, resource_group, workspace_name):
    """Get Azure ML Client."""
    try:
        credential = DefaultAzureCredential()
    except Exception:
        credential = AzureCliCredential()
    
    return MLClient(
        credential=credential,
        subscription_id=subscription_id,
        resource_group_name=resource_group,
        workspace_name=workspace_name
    )

def register_model(ml_client, model_path, model_name="nba-playoff-model"):
    """Register the model in Azure ML."""
    print(f"\n📦 Registering model: {model_name}")
    
    model = Model(
        path=model_path,
        name=model_name,
        description="Random Forest model for NBA playoff prediction",
        type=AssetTypes.CUSTOM_MODEL
    )
    
    registered_model = ml_client.models.create_or_update(model)
    print(f"✅ Model registered: {registered_model.id}")
    return registered_model

def create_endpoint(ml_client, endpoint_name="nba-oracle-endpoint"):
    """Create managed online endpoint."""
    print(f"\n🌐 Creating endpoint: {endpoint_name}")
    
    endpoint = ManagedOnlineEndpoint(
        name=endpoint_name,
        description="Basketball playoff prediction endpoint",
        auth_mode="key",
    )
    
    created_endpoint = ml_client.online_endpoints.begin_create_or_update(
        endpoint
    ).result()
    
    print(f"✅ Endpoint created: {created_endpoint.scoring_uri}")
    return created_endpoint

def create_deployment(ml_client, endpoint_name, model_id, deployment_name="playoff-deploy"):
    """Create model deployment."""
    print(f"\n🚀 Creating deployment: {deployment_name}")
    
    deployment = ManagedOnlineDeployment(
        name=deployment_name,
        endpoint_name=endpoint_name,
        model=model_id,
        instance_type="Standard_F2s_v2",
        instance_count=1,
    )
    
    created_deployment = ml_client.online_deployments.begin_create_or_update(
        deployment
    ).result()
    
    print(f"✅ Deployment created: {deployment_name}")
    return created_deployment

def get_endpoint_details(ml_client, endpoint_name):
    """Get endpoint details."""
    endpoint = ml_client.online_endpoints.get(endpoint_name)
    
    print(f"\n📋 Endpoint Details:")
    print(f"  URI: {endpoint.scoring_uri}")
    print(f"  Auth Mode: {endpoint.auth_mode}")
    
    # Get key
    keys = ml_client.online_endpoints.get_keys(endpoint_name)
    print(f"  Primary Key: {keys.primary_key[:20]}...")
    
    return {
        "uri": endpoint.scoring_uri,
        "key": keys.primary_key
    }

def save_deployment_config(endpoint_details, output_file="ml/.env.deployment"):
    """Save deployment configuration."""
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    config = {
        "ML_MODEL_ENDPOINT": endpoint_details["uri"],
        "ML_API_KEY": endpoint_details["key"]
    }
    
    with open(output_file, "w") as f:
        for key, value in config.items():
            f.write(f"{key}={value}\n")
    
    print(f"\n✅ Configuration saved to {output_file}")
    return config

def test_endpoint(endpoint_details):
    """Test the deployed endpoint."""
    import requests
    
    print(f"\n🧪 Testing endpoint...")
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {endpoint_details['key']}"
    }
    
    # Sample input
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
    
    try:
        response = requests.post(
            endpoint_details["uri"],
            json=data,
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Endpoint test successful!")
            print(f"   Response: {result}")
            return True
        else:
            print(f"⚠️  Endpoint returned status {response.status_code}")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"⚠️  Could not test endpoint: {str(e)}")
        return False

def main():
    """Main deployment pipeline."""
    print("=" * 60)
    print("🚀 Azure ML Model Deployment")
    print("=" * 60)
    
    # Get configuration from environment
    subscription_id = os.getenv("AZURE_SUBSCRIPTION_ID")
    resource_group = os.getenv("AZURE_RESOURCE_GROUP")
    workspace_name = os.getenv("AZURE_ML_WORKSPACE")
    
    if not all([subscription_id, resource_group, workspace_name]):
        print("\n❌ Missing Azure configuration!")
        print("Set these environment variables:")
        print("  - AZURE_SUBSCRIPTION_ID")
        print("  - AZURE_RESOURCE_GROUP")
        print("  - AZURE_ML_WORKSPACE")
        return
    
    # Initialize ML client
    print(f"\n🔐 Connecting to Azure ML...")
    print(f"  Subscription: {subscription_id[:20]}...")
    print(f"  Workspace: {workspace_name}")
    
    ml_client = get_ml_client(subscription_id, resource_group, workspace_name)
    
    # Register model
    model_path = "ml/models/nba_playoff_model.pkl"
    if not os.path.exists(model_path):
        print(f"\n❌ Model file not found: {model_path}")
        print("   Run 'python ml/train_model.py' first")
        return
    
    registered_model = register_model(ml_client, model_path)
    
    # Create endpoint
    endpoint_name = "nba-oracle-endpoint"
    try:
        endpoint = ml_client.online_endpoints.get(endpoint_name)
        print(f"\n✅ Endpoint already exists: {endpoint_name}")
    except:
        endpoint = create_endpoint(ml_client, endpoint_name)
    
    # Create deployment
    try:
        deployment = create_deployment(
            ml_client, endpoint_name, registered_model.id
        )
        print(f"✅ Deployment active: {deployment.name}")
    except Exception as e:
        print(f"⚠️  Deployment creation: {str(e)}")
    
    # Get endpoint details
    endpoint_details = get_endpoint_details(ml_client, endpoint_name)
    
    # Save configuration
    config = save_deployment_config(endpoint_details)
    
    # Test endpoint
    test_endpoint(endpoint_details)
    
    print("\n" + "=" * 60)
    print("✅ Deployment Complete!")
    print("=" * 60)
    print(f"\nNext steps:")
    print(f"1. Copy the ML_API_KEY to GitHub Secrets")
    print(f"2. Update your .env file with endpoint details")
    print(f"3. Use the endpoint in your frontend code")

if __name__ == "__main__":
    main()
