# GitHub Secrets Setup - Manual Method

Since your Azure account doesn't have AD permissions to create service principals programmatically, follow these manual steps:

## Step 1: Go to Azure Portal and Create a Service Principal

1. Go to: https://portal.azure.com
2. Navigate to **Azure Active Directory** > **App registrations**
3. Click **New registration**
4. Fill in:
   - Name: `github-actions-nba-oracle`
   - Supported account types: **Single tenant**
   - Click **Register**

## Step 2: Create a Client Secret

1. In the app you just created, go to **Certificates & secrets**
2. Click **New client secret**
3. Description: `github-actions-secret`
4. Expires: **24 months**
5. Click **Add**
6. **COPY** the secret Value immediately (you won't see it again!)

## Step 3: Get Your Credentials

You now have these values (from the app overview page):
- **Application (client) ID**: Copy this
- **Directory (tenant) ID**: Copy this
- **Client Secret**: You copied this in Step 2

Your subscription ID is: `2ee61742-e4b7-4e3a-90c9-11d13557d797`

## Step 4: Create the JSON for GitHub

Combine those 4 values into this JSON format:

```json
{
  "clientId": "[CLIENT_ID_FROM_STEP_3]",
  "clientSecret": "[CLIENT_SECRET_FROM_STEP_2]",
  "subscriptionId": "2ee61742-e4b7-4e3a-90c9-11d13557d797",
  "tenantId": "[TENANT_ID_FROM_STEP_3]"
}
```

## Step 5: Add 3 GitHub Secrets

1. Go to: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/settings/secrets/actions

2. Click **New repository secret**

3. **SECRET 1:**
   - Name: `AZURE_CREDENTIALS`
   - Value: [Paste the JSON from Step 4]
   - Click **Add secret**

4. **SECRET 2:**
   - Name: `STORAGE_ACCOUNT`
   - Value: `nbaoraclestats`
   - Click **Add secret**

5. **SECRET 3:**
   - Name: `RESOURCE_GROUP`
   - Value: `nba-finals`
   - Click **Add secret**

## Step 6: Deploy!

```powershell
cd d:\cldcpm\CLOUD-NBA-FINALS
git add .
git commit -m "fix: add github secrets and enable deployment"
git push origin main
```

## Step 7: Watch Deployment

Go to: https://github.com/monmonmendoza10/CLOUD-NBA-FINALS/actions

Wait for the workflow to complete (2-3 minutes), then visit:
```
https://nbaoraclestats.z7.web.core.windows.net/
```

That's it! Your ML predictions will be live! 🎉

---

**Questions?** The local version at `http://127.0.0.1:8000` is already working if you need to test predictions locally first.
