# Terraform Infrastructure

## Required Secrets for GitHub Actions

Add these 4 secrets to your GitHub repository (**Settings → Secrets → Actions**):

### 1. AZURE_CREDENTIALS
Azure Service Principal JSON:
```bash
az ad sp create-for-rbac --name "burger-builder-sp" --role contributor --scopes /subscriptions/YOUR_SUB_ID --sdk-auth
```

### 2. DOCKERHUB_USERNAME
Your Docker Hub username (e.g., `uo3d`)

### 3. DOCKERHUB_TOKEN
Token from https://hub.docker.com/settings/security

### 4. TF_VARS
Copy the entire content of `terraform.tfvars` file (plain text, including password)

---

## Manual Deployment

```bash
# Initialize
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply

# Get outputs
terraform output

# Destroy everything
terraform destroy
```

---

## Resources Created

- **Resource Group**: `naser-burger-builder-rg`
- **Virtual Network**: 3 subnets (app, database, gateway)
- **Container Apps**: Frontend + Backend with autoscaling (1-10 instances)
- **Application Gateway**: Load balancer with path routing
- **Azure SQL Database**: Private endpoint only (no public access)
- **Log Analytics**: Monitoring and logs

**Resource Naming**: All resources prefixed with `naser-` for uniqueness in shared subscriptions

**Estimated Cost**: ~$160-180/month

---

## Infrastructure Overview

```
Virtual Network (10.0.0.0/16) - naser-burger-builder-vnet
├── App Subnet (10.0.2.0/23)
│   └── Container App Environment - naser-burger-builder-app-env
│       ├── Frontend Container (React + Nginx)
│       └── Backend Container (Spring Boot)
├── Database Subnet (10.0.4.0/24)
│   └── SQL Private Endpoint - naser-burger-builder-sql
└── Gateway Subnet (10.0.1.0/24)
    └── Application Gateway (Public IP) - naser-burger-builder-appgw
```

---

## Access After Deployment

```bash
# Get Application Gateway IP
terraform output app_gateway_public_ip

# Access URLs
terraform output app_gateway_url              # Main app
terraform output app_gateway_api_url          # Backend API
terraform output app_gateway_health_url       # Health check
```

Your app will be available at: `http://<GATEWAY_IP>/`

---

## Configuration

Key variables in `terraform.tfvars`:

- **Location**: Azure region (South Africa North)
- **Container Images**: Docker Hub images for frontend/backend
- **CPU/Memory**: Container resource limits
- **Scaling**: Min/max replica counts
- **SQL Credentials**: Database admin username/password

---

## Security Features

- Container apps not directly accessible from internet
- All traffic routes through Application Gateway
- SQL Database uses private endpoint (VNet-only access)
- CORS configured for frontend domain
- Auto-scaling based on load

---

## Troubleshooting

### "Terraform init fails"
```bash
# Clear cache and reinitialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### "SQL password doesn't meet requirements"
Password must have:
- Minimum 8 characters
- Uppercase letters (A-Z)
- Lowercase letters (a-z)
- Numbers (0-9)
- Special characters (@, !, #, $, %, etc.)

### "Container apps unhealthy"
```bash
# Check container logs
az containerapp logs show --name backend-app --resource-group naser-burger-builder-rg --follow
```

### "Application Gateway returns 502"
- Wait 2-3 minutes for containers to fully start
- Check backend health: `curl http://<GATEWAY_IP>/actuator/health`

---

**For complete deployment instructions, see the main [README.md](../README.md)**
