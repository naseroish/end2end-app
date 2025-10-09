# 🍔 Burger Builder - Operations Runbook

## 📖 Overview
This runbook provides step-by-step operational procedures for deploying, monitoring, and troubleshooting the Burger Builder application on Azure Container Apps.

**Last Updated**: October 9, 2025  
**Version**: 1.0  
**Owner**: Naser

---

## 🎯 Quick Links

- **Production URL**: `http://<APP_GATEWAY_IP>/`
- **Backend API**: `http://<APP_GATEWAY_IP>/api`
- **Health Endpoint**: `http://<APP_GATEWAY_IP>/actuator/health`
- **SonarCloud Dashboard**: https://sonarcloud.io/organizations/naseroish
- **GitHub Actions**: https://github.com/naseroish/end2end-app/actions
- **Azure Portal**: https://portal.azure.com

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Deployment Procedures](#deployment-procedures)
4. [Validation & Testing](#validation--testing)
5. [Monitoring & Alerts](#monitoring--alerts)
6. [Troubleshooting](#troubleshooting)
7. [Rollback Procedures](#rollback-procedures)
8. [Maintenance](#maintenance)
9. [Emergency Contacts](#emergency-contacts)

---

## Prerequisites

### Required Tools
```bash
# Azure CLI (version 2.50+)
az --version

# Terraform (version 1.7+)
terraform --version

# Docker (version 24+)
docker --version

# Git
git --version
```

### Required Access
- ✅ Azure Subscription with Contributor role
- ✅ GitHub repository admin access
- ✅ Docker Hub account with push permissions
- ✅ SonarCloud account (free for public repos)

### Budget Considerations
- **Monthly Cost**: ~$160-180 USD
- **Resources**: Container Apps, Application Gateway, Azure SQL, VNet
- **Auto-scaling**: 1-10 instances (cost scales with usage)

---

## Initial Setup

### Step 1: Azure Service Principal Creation
```bash
# Create service principal for GitHub Actions
az ad sp create-for-rbac \
  --name "burger-builder-sp" \
  --role contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> \
  --sdk-auth > azure-credentials.json

# Save the output - you'll need it for GitHub Secrets
cat azure-credentials.json
```

**Expected Output**:
```json
{
  "clientId": "xxx",
  "clientSecret": "xxx",
  "subscriptionId": "xxx",
  "tenantId": "xxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  ...
}
```

### Step 2: Docker Hub Setup
1. Login to https://hub.docker.com
2. Navigate to **Account Settings** → **Security** → **New Access Token**
3. Name: `burger-builder-github`
4. Permissions: **Read & Write**
5. Copy token immediately (shown only once)

### Step 3: SonarCloud Setup
1. Sign up at https://sonarcloud.io with GitHub account
2. Import your repository: `naseroish/end2end-app`
3. Navigate to **My Account** → **Security**
4. Click **Generate Token**:
   - Name: `burger-builder-github`
   - Type: **User Token**
   - Expiration: **No expiration**
5. Copy token immediately

### Step 4: Configure GitHub Secrets
Navigate to: **GitHub Repo** → **Settings** → **Secrets and variables** → **Actions**

Add these 5 secrets:

| Secret Name | Value | Notes |
|-------------|-------|-------|
| `AZURE_CREDENTIALS` | Full JSON from Step 1 | Entire output including braces |
| `DOCKERHUB_USERNAME` | Your Docker Hub username | Case-sensitive |
| `DOCKERHUB_TOKEN` | Token from Step 2 | Starts with `dckr_pat_` |
| `SONAR_TOKEN` | Token from Step 3 | Long alphanumeric string |
| `TF_VARS` | Content of `terraform/terraform.tfvars` | Plain text, not JSON |

**TF_VARS Example**:
```hcl
location            = "West Europe"
sql_admin_password  = "YourSecurePassword123!"
```

---

## Deployment Procedures

### Standard Deployment (GitHub Actions)

#### 1. Pre-Deployment Checklist
- [ ] All code changes committed and pushed
- [ ] All tests passing locally
- [ ] GitHub Secrets configured
- [ ] No active incidents
- [ ] Backup of current state completed

#### 2. Trigger Deployment
```bash
# Push code to master branch
git add .
git commit -m "Deploy: <description of changes>"
git push origin master

# OR manually trigger via GitHub UI:
# 1. Go to Actions tab
# 2. Select "🚀 Deploy Burger Builder to Azure Container Apps"
# 3. Click "Run workflow"
# 4. Select branch: master
# 5. Action: deploy
# 6. Click "Run workflow" button
```

#### 3. Monitor Deployment
```bash
# Watch GitHub Actions progress
# Expected duration: 15-20 minutes

# Deployment stages:
# ✅ Backend Analysis (SonarCloud) - 3 min
# ✅ Frontend Analysis (SonarCloud) - 2 min
# ✅ Build & Push Docker Images - 5 min
# ✅ Deploy Infrastructure (Terraform) - 8 min
# ✅ Health Checks & Verification - 2 min
```

#### 4. Post-Deployment Validation
See [Validation & Testing](#validation--testing) section below.

---

### Manual Deployment (Local)

#### Prerequisites
```bash
# Login to Azure
az login

# Login to Docker Hub
docker login --username <YOUR_USERNAME>

# Verify Terraform variables
cd terraform
cat terraform.tfvars
```

#### Build and Push Images
```bash
# Build Frontend
cd frontend
docker build -t <your-dockerhub>/burger-builder-frontend:latest .
docker push <your-dockerhub>/burger-builder-frontend:latest

# Build Backend
cd ../backend
docker build -t <your-dockerhub>/burger-builder-backend:latest .
docker push <your-dockerhub>/burger-builder-backend:latest
```

#### Deploy Infrastructure
```bash
cd ../terraform

# Initialize Terraform
terraform init

# Review plan
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Save outputs
terraform output > ../deployment-outputs.txt
```

#### Get Deployment Details
```bash
# Get resource group
RG=$(terraform output -raw resource_group_name)

# Get Application Gateway IP
az network public-ip show \
  --resource-group $RG \
  --name naser-burger-builder-appgw-pip \
  --query ipAddress -o tsv

# Get Container App URLs
az containerapp show \
  --name frontend-app \
  --resource-group $RG \
  --query "properties.configuration.ingress.fqdn" -o tsv

az containerapp show \
  --name backend-app \
  --resource-group $RG \
  --query "properties.configuration.ingress.fqdn" -o tsv
```

---

## Validation & Testing

### Health Check Endpoints

#### Backend Health
```bash
# Basic health check
curl -i http://<APP_GATEWAY_IP>/actuator/health

# Expected Response:
# HTTP/1.1 200 OK
# {"status":"UP"}

# Detailed health (if actuator endpoints exposed)
curl http://<APP_GATEWAY_IP>/actuator/health/liveness
curl http://<APP_GATEWAY_IP>/actuator/health/readiness
```

#### Frontend Health
```bash
# Check frontend is serving
curl -I http://<APP_GATEWAY_IP>/

# Expected Response:
# HTTP/1.1 200 OK
# Content-Type: text/html
```

### API Endpoint Testing

#### 1. List All Ingredients
```bash
curl -X GET "http://<APP_GATEWAY_IP>/api/ingredients" \
  -H "Accept: application/json" | jq

# Expected Response:
# [
#   {
#     "id": 1,
#     "name": "Lettuce",
#     "category": "VEGETABLE",
#     "price": 0.50
#   },
#   ...
# ]
```

#### 2. Create Cart Item
```bash
# Generate session ID
SESSION_ID=$(uuidgen)

# Add item to cart
curl -X POST "http://<APP_GATEWAY_IP>/api/cart/items" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "'$SESSION_ID'",
    "ingredientId": 1,
    "quantity": 2
  }' | jq

# Expected Response:
# {
#   "id": 123,
#   "sessionId": "...",
#   "ingredient": {...},
#   "quantity": 2
# }
```

#### 3. Get Cart Contents
```bash
curl -X GET "http://<APP_GATEWAY_IP>/api/cart/$SESSION_ID" \
  -H "Accept: application/json" | jq

# Expected Response:
# {
#   "items": [...],
#   "totalPrice": 1.00
# }
```

#### 4. Create Order
```bash
curl -X POST "http://<APP_GATEWAY_IP>/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "'$SESSION_ID'",
    "customerName": "John Doe",
    "deliveryAddress": "123 Main St"
  }' | jq

# Expected Response:
# {
#   "orderId": 456,
#   "status": "PENDING",
#   "totalPrice": 1.00,
#   "createdAt": "2025-10-09T..."
# }
```

#### 5. Get Order History
```bash
curl -X GET "http://<APP_GATEWAY_IP>/api/orders/history" \
  -H "Accept: application/json" | jq

# Expected Response:
# [
#   {
#     "orderId": 456,
#     "customerName": "John Doe",
#     "totalPrice": 1.00,
#     "status": "PENDING"
#   }
# ]
```

### UI Testing (Manual)

#### Test Scenario 1: Build a Burger
1. Navigate to `http://<APP_GATEWAY_IP>/`
2. Click on ingredient categories (Protein, Vegetables, etc.)
3. Select ingredients to add to burger
4. Verify burger preview updates in real-time
5. Check total price updates correctly

#### Test Scenario 2: Cart Management
1. Add multiple items to cart
2. Verify cart icon shows item count
3. Open cart view
4. Update item quantities
5. Remove items
6. Verify price calculations

#### Test Scenario 3: Order Placement
1. Build a burger with items
2. Click "Checkout" or "Place Order"
3. Fill in customer information
4. Submit order
5. Verify order confirmation message
6. Check order appears in history

### Database Validation
```bash
# Connect to Azure SQL (from allowed IP)
RG=$(terraform output -raw resource_group_name)
SQL_SERVER=$(az sql server list --resource-group $RG --query "[0].name" -o tsv)

# Run queries
az sql db query \
  --server $SQL_SERVER \
  --name burgerdb \
  --admin-user sqladmin \
  --admin-password '<YOUR_PASSWORD>' \
  --queries "SELECT COUNT(*) as total_ingredients FROM ingredients;"

az sql db query \
  --server $SQL_SERVER \
  --name burgerdb \
  --admin-user sqladmin \
  --admin-password '<YOUR_PASSWORD>' \
  --queries "SELECT COUNT(*) as total_orders FROM orders;"
```

---

## Monitoring & Alerts

### View Container Logs

#### Real-time Logs
```bash
RG="naser-burger-builder-rg"

# Backend logs
az containerapp logs show \
  --name backend-app \
  --resource-group $RG \
  --follow

# Frontend logs
az containerapp logs show \
  --name frontend-app \
  --resource-group $RG \
  --follow

# Filter by time
az containerapp logs show \
  --name backend-app \
  --resource-group $RG \
  --since 1h
```

#### Log Analytics Queries
```bash
# Get Log Analytics Workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --workspace-name naser-burger-builder-log-analytics \
  --resource-group $RG \
  --query customerId -o tsv)

# Query logs (example)
az monitor log-analytics query \
  --workspace $WORKSPACE_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where TimeGenerated > ago(1h) | limit 100"
```

### Application Gateway Health

#### Check Backend Health
```bash
az network application-gateway show-backend-health \
  --name naser-burger-builder-appgw \
  --resource-group naser-burger-builder-rg

# Expected Output:
# {
#   "backendAddressPools": [
#     {
#       "backendHttpSettingsCollection": [
#         {
#           "servers": [
#             {
#               "health": "Healthy",
#               ...
#             }
#           ]
#         }
#       ]
#     }
#   ]
# }
```

### Container App Metrics

#### CPU & Memory Usage
```bash
# Get replica status
az containerapp replica list \
  --name backend-app \
  --resource-group $RG \
  --output table

# Get revision status
az containerapp revision list \
  --name backend-app \
  --resource-group $RG \
  --output table
```

### SonarCloud Quality Gates

#### Check Quality Status
1. Visit https://sonarcloud.io/organizations/naseroish
2. Navigate to project: **Burger Builder Backend** or **Frontend**
3. Review:
   - **Bugs**: Should be 0
   - **Vulnerabilities**: Should be 0
   - **Code Coverage**: Target >70%
   - **Code Smells**: Review and address
   - **Security Hotspots**: Review and fix

---

## Troubleshooting

### Issue 1: Deployment Fails in GitHub Actions

#### Symptoms
- GitHub Actions workflow fails
- Red X on workflow run

#### Diagnosis
```bash
# Check workflow logs in GitHub Actions tab
# Common failures:
# - SonarCloud analysis failed
# - Docker build/push failed
# - Terraform apply failed
```

#### Resolution
1. **SonarCloud Failure**:
   ```bash
   # Verify SONAR_TOKEN secret is set
   # Check SonarCloud organization: naseroish
   # Verify project keys match workflow
   ```

2. **Docker Build Failure**:
   ```bash
   # Verify DOCKERHUB_USERNAME and DOCKERHUB_TOKEN
   # Check Docker Hub rate limits
   # Test build locally
   cd backend && docker build -t test:latest .
   ```

3. **Terraform Failure**:
   ```bash
   # Verify TF_VARS secret is correctly formatted
   # Check Azure quota limits
   # Review Terraform state
   ```

---

### Issue 2: Application Gateway Returns 502

#### Symptoms
- Browser shows "502 Bad Gateway"
- Unable to access application

#### Diagnosis
```bash
# Check backend health
az network application-gateway show-backend-health \
  --name naser-burger-builder-appgw \
  --resource-group naser-burger-builder-rg

# Check container app status
az containerapp show \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --query "properties.runningStatus" -o tsv
```

#### Resolution
1. **Wait for startup**: Container apps may take 2-3 minutes to fully start
2. **Check logs**:
   ```bash
   az containerapp logs show \
     --name backend-app \
     --resource-group naser-burger-builder-rg \
     --tail 100
   ```
3. **Restart container**:
   ```bash
   az containerapp revision restart \
     --name backend-app \
     --resource-group naser-burger-builder-rg \
     --revision <revision-name>
   ```

---

### Issue 3: Database Connection Errors

#### Symptoms
- Backend logs show "Connection refused"
- API returns 500 errors

#### Diagnosis
```bash
# Check database status
az sql db show \
  --server naser-burger-builder-sql \
  --name burgerdb \
  --resource-group naser-burger-builder-rg

# Check firewall rules
az sql server firewall-rule list \
  --server naser-burger-builder-sql \
  --resource-group naser-burger-builder-rg
```

#### Resolution
```bash
# Verify connection string
az containerapp show \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --query "properties.configuration.secrets"

# Test database connectivity
az sql db show-connection-string \
  --server naser-burger-builder-sql \
  --name burgerdb \
  --client jdbc
```

---

### Issue 4: High Costs / Runaway Scaling

#### Symptoms
- Azure costs higher than expected
- Too many container replicas running

#### Diagnosis
```bash
# Check current replica count
az containerapp replica list \
  --name backend-app \
  --resource-group naser-burger-builder-rg

# Check scaling rules
az containerapp show \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --query "properties.template.scale"
```

#### Resolution
```bash
# Update max replicas
az containerapp update \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --max-replicas 3

# Or destroy infrastructure when not in use
cd terraform && terraform destroy
```

---

## Rollback Procedures

### Rollback Container App Revision

#### Identify Previous Revision
```bash
# List all revisions
az containerapp revision list \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --output table

# Example output:
# Name                           Active    Created
# backend-app--rev1-abc123       False     2025-10-09T10:00:00
# backend-app--rev2-def456       True      2025-10-09T14:00:00
```

#### Activate Previous Revision
```bash
# Deactivate current revision
az containerapp revision deactivate \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --revision backend-app--rev2-def456

# Activate previous revision
az containerapp revision activate \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --revision backend-app--rev1-abc123

# Verify
az containerapp revision list \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --output table
```

### Rollback Terraform Changes

#### Using Git
```bash
# Find previous working commit
git log --oneline

# Checkout previous version
git checkout <commit-hash> terraform/

# Apply previous infrastructure
cd terraform
terraform plan
terraform apply
```

---

## Maintenance

### Scheduled Maintenance Tasks

#### Weekly
- [ ] Review SonarCloud quality gate reports
- [ ] Check Azure cost analysis dashboard
- [ ] Review container logs for errors
- [ ] Verify backup jobs completed

#### Monthly
- [ ] Update dependencies (npm, Maven)
- [ ] Review and optimize scaling rules
- [ ] Test disaster recovery procedures
- [ ] Review and update documentation

#### Quarterly
- [ ] Update Docker base images
- [ ] Review Azure reserved instances for cost savings
- [ ] Conduct security audit
- [ ] Update runbook with lessons learned

---

### Updating Dependencies

#### Backend (Java/Maven)
```bash
cd backend

# Check for updates
mvn versions:display-dependency-updates

# Update Spring Boot version in pom.xml
# Run tests
mvn clean verify

# Rebuild and redeploy
docker build -t <your-dockerhub>/burger-builder-backend:latest .
docker push <your-dockerhub>/burger-builder-backend:latest
```

#### Frontend (Node/npm)
```bash
cd frontend

# Check for updates
npm outdated

# Update dependencies
npm update

# Run tests
npm run test:coverage

# Rebuild and redeploy
docker build -t <your-dockerhub>/burger-builder-frontend:latest .
docker push <your-dockerhub>/burger-builder-frontend:latest
```

---

## Emergency Contacts

### Escalation Path

| Level | Role | Contact | Response Time |
|-------|------|---------|---------------|
| L1 | On-Call DevOps | devops@example.com | 15 minutes |
| L2 | Lead Developer | lead-dev@example.com | 30 minutes |
| L3 | Cloud Architect | architect@example.com | 1 hour |

### External Contacts

- **Azure Support**: https://portal.azure.com → Support
- **GitHub Support**: https://support.github.com
- **SonarCloud Support**: support@sonarsource.com

---

## Appendix

### Useful Commands Cheat Sheet

```bash
# Quick health check
curl -s http://<APP_GATEWAY_IP>/actuator/health | jq

# Tail logs
az containerapp logs show --name backend-app --resource-group naser-burger-builder-rg --follow

# Check costs
az consumption usage list --start-date 2025-10-01 --end-date 2025-10-09 --output table

# Force redeploy
az containerapp revision restart --name backend-app --resource-group naser-burger-builder-rg

# Destroy everything (DANGER!)
cd terraform && terraform destroy --auto-approve
```

### Common Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| 502 | Bad Gateway | Check container health, wait for startup |
| 503 | Service Unavailable | Check scaling limits, increase replicas |
| 500 | Internal Server Error | Check backend logs, verify DB connection |
| 404 | Not Found | Verify routing rules, check deployment |

---

**Document Version**: 1.0  
**Last Review**: October 9, 2025  
**Next Review**: January 9, 2026
