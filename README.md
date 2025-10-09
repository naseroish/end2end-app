# 🍔 Burger Builder - Full Stack Application

A production-ready full-stack application for building and ordering custom burgers with automated CI/CD deployment to Azure.

**Tech Stack**: React 19 + TypeScript | Spring Boot 3.2 + Java 21 | Azure Container Apps | Terraform | GitHub Actions

---

## 🏗️ Infrastructure Created
- Virtual Network with 3 subnets
- Container App Environment with auto-scaling (1-10 instances)
- Application Gateway with path-based routing
- Azure SQL Database with private endpoint
- Log Analytics for monitoring

**Resource Naming**: All resources prefixed with `naser-` to avoid conflicts in shared subscriptions

**Monthly Cost**: ~$160-180 USD

---

## 🚀 Quick Deploy to Azure

### Prerequisites
- Azure subscription with active credits
- GitHub account
- Docker Hub account

### 1️⃣ Create Azure Service Principal (2 min)

```bash
az ad sp create-for-rbac \
  --name "burger-builder-sp" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth
```
**Save the entire JSON output!**

### 2️⃣ Get Docker Hub Token (1 min)

1. Go to https://hub.docker.com/settings/security
2. Click **"New Access Token"**
3. Name: `burger-builder-github`, Permissions: Read & Write
4. **Copy the token!**

### 3️⃣ Configure GitHub Secrets (3 min)

Go to your repo: **Settings** → **Secrets and variables** → **Actions**

Add these 5 secrets:

| Secret Name | Value | Where to Get |
|-------------|-------|--------------|
| `AZURE_CREDENTIALS` | Full JSON from step 1 | Azure Service Principal |
| `DOCKERHUB_USERNAME` | Your Docker Hub username | Docker Hub profile |
| `DOCKERHUB_TOKEN` | Token from step 2 | Docker Hub security |
| `SONAR_TOKEN` | SonarCloud token | SonarCloud account (see below) |
| `TF_VARS` | Copy from `terraform/terraform.tfvars` | Local file (plain text, with password) |

**Important**: `TF_VARS` must be **plain text** (not JSON). Copy the entire content of `terraform/terraform.tfvars` including the SQL password.

#### 🔍 Getting SonarCloud Token:
1. Sign up at https://sonarcloud.io (free for public repos)
2. Go to **My Account** → **Security** → **Generate Token**
3. Name: `burger-builder-github`, Type: User Token
4. Copy the token and add it to GitHub Secrets as `SONAR_TOKEN`

### 4️⃣ Deploy! (15 min)

1. Push your code to GitHub:
   ```bash
   git add .
   git commit -m "Deploy to Azure"
   git push origin master
   ```

2. Go to **Actions** tab → **"🚀 Deploy Burger Builder to Azure Container Apps"**

3. Click **"Run workflow"** → Select `deploy` → Click green **"Run workflow"** button

4. Wait ~27 minutes. The workflow will:
   - ✅ Analyze code quality (SonarCloud)
   - ✅ Build Docker images
   - ✅ Deploy infrastructure (Terraform)
   - ✅ Run health checks

5. **Access your app**: Check workflow summary for Application Gateway IP
   ```
   🎉 Your app is live at: http://<GATEWAY_IP>/
   ```

---

## 🏗️ Architecture

```
Internet → Application Gateway (Public IP)
    ↓
    ├─→ Path: /           → Frontend Container App (React + Nginx)
    └─→ Path: /api/*      → Backend Container App (Spring Boot)
                                ↓
                        Azure SQL Database (Private Endpoint)
```

**Infrastructure Created**:
- Virtual Network with 3 subnets
- Container App Environment with auto-scaling (1-10 instances)
- Application Gateway with path-based routing
- Azure SQL Database with private endpoint
- Log Analytics for monitoring

**Monthly Cost**: ~$160-180 USD

---

## 💻 Local Development

### Backend (Spring Boot + PostgreSQL)

```bash
# Start PostgreSQL + Backend with Docker Compose
cd backend
docker-compose up --build

# Backend runs on: http://localhost:8080
# API docs: http://localhost:8080/actuator/health
```

**Environment Variables** (auto-configured in docker-compose.yml):
- `SPRING_PROFILES_ACTIVE=docker`
- Database: PostgreSQL on port 5432

### Frontend (React + Vite)

```bash
cd frontend
npm install
npm run dev

# Frontend runs on: http://localhost:5173
```

**Configuration**:
- Backend API URL: Set `VITE_API_BASE_URL` in `.env` file
- Default: `http://localhost:8080`

### Run Tests

```bash
# Backend tests
cd backend
mvn clean verify

# Frontend tests
cd frontend
npm run test:coverage
```

---

## 📋 Project Structure

```
end2end-app/
├── frontend/                    # React application
│   ├── src/
│   │   ├── components/         # React components
│   │   ├── context/            # State management
│   │   ├── services/           # API client
│   │   └── types/              # TypeScript types
│   ├── Dockerfile              # Multi-stage build
│   ├── nginx.conf              # Production web server config
│   └── package.json
│
├── backend/                     # Spring Boot API
│   ├── src/main/java/com/burgerbuilder/
│   │   ├── controller/         # REST endpoints
│   │   ├── service/            # Business logic
│   │   ├── repository/         # Data access
│   │   └── entity/             # Database models
│   ├── src/main/resources/
│   │   ├── application.properties           # Default config
│   │   ├── application-docker.properties    # PostgreSQL
│   │   ├── application-azure.properties     # Azure SQL
│   │   ├── schema.sql          # Database schema
│   │   └── data.sql            # Initial data
│   ├── Dockerfile              # Multi-stage build
│   ├── docker-compose.yml      # Local development
│   └── pom.xml
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Main configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── terraform.tfvars        # Variable values (add to secrets)
│   └── modules/                # Reusable modules
│
└── .github/workflows/
    └── deploy.yml              # CI/CD pipeline
```

---

## 🔧 CI/CD Pipeline

The GitHub Actions workflow automates the entire deployment:

```
1. 🔍 Code Quality Analysis (SonarCloud)
   ├─ Backend: Bugs, vulnerabilities, coverage
   └─ Frontend: Code smells, security, coverage
   
2. 🔨 Build & Push Docker Images
   ├─ Frontend: your-dockerhub/burger-builder-frontend:latest
   └─ Backend: your-dockerhub/burger-builder-backend:latest
   
3. 🏗️ Deploy Infrastructure (Terraform)
   ├─ Virtual Network + Subnets
   ├─ Container Apps (Frontend + Backend)
   ├─ Application Gateway
   ├─ Azure SQL Database
   └─ Log Analytics
   
4. 🧪 Health Checks & Verification
   ├─ Frontend health
   ├─ Backend API health
   └─ Database connectivity
```

**Trigger**: Manual workflow dispatch or push to master (configurable)

---

## 🌐 API Endpoints

### Ingredients
- `GET /api/ingredients` - List all ingredients
- `GET /api/ingredients/{category}` - Filter by category

### Cart Management
- `POST /api/cart/items` - Add item to cart
- `GET /api/cart/{sessionId}` - Get cart contents
- `PUT /api/cart/items/{itemId}` - Update cart item
- `DELETE /api/cart/items/{itemId}` - Remove from cart
- `DELETE /api/cart/{sessionId}` - Clear cart

### Orders
- `POST /api/orders` - Create new order
- `GET /api/orders/{orderId}` - Get order details
- `GET /api/orders/history` - List all orders

### Health
- `GET /actuator/health` - Application health status

**Testing with curl**:
```bash
# Replace <GATEWAY_IP> with your Application Gateway IP

# Test health endpoint
curl http://<GATEWAY_IP>/actuator/health

# Get all ingredients
curl http://<GATEWAY_IP>/api/ingredients

# Get ingredients by category
curl http://<GATEWAY_IP>/api/ingredients/PROTEIN

# Add item to cart (replace SESSION_ID with your session)
curl -X POST http://<GATEWAY_IP>/api/cart/items \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test-session-123",
    "ingredientId": 1,
    "quantity": 2
  }'

# Get cart contents
curl http://<GATEWAY_IP>/api/cart/test-session-123

# Place order
curl -X POST http://<GATEWAY_IP>/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test-session-123",
    "customerName": "John Doe",
    "deliveryAddress": "123 Main St"
  }'

# Get order history
curl http://<GATEWAY_IP>/api/orders/history
```

**Testing with PowerShell**:
```powershell
# Test health endpoint
Invoke-RestMethod -Uri "http://<GATEWAY_IP>/actuator/health" -Method Get

# Get all ingredients
Invoke-RestMethod -Uri "http://<GATEWAY_IP>/api/ingredients" -Method Get | ConvertTo-Json

# Add item to cart
$body = @{
    sessionId = "test-session-123"
    ingredientId = 1
    quantity = 2
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://<GATEWAY_IP>/api/cart/items" `
  -Method Post `
  -ContentType "application/json" `
  -Body $body
```

---

## ✅ Deployment Validation

### Post-Deployment Checklist

After deployment completes, validate the application is working correctly:

#### 1. Check Deployment Status (2 min)
```bash
# Get resource group
az group show --name naser-burger-builder-rg

# Verify Container Apps are running
az containerapp show --name frontend-app --resource-group naser-burger-builder-rg --query "properties.runningStatus"
az containerapp show --name backend-app --resource-group naser-burger-builder-rg --query "properties.runningStatus"

# Get Application Gateway IP
az network public-ip show \
  --resource-group naser-burger-builder-rg \
  --name naser-burger-builder-appgw-pip \
  --query ipAddress -o tsv
```

#### 2. Test Health Endpoints (1 min)
```bash
# Replace <GATEWAY_IP> with your actual IP
GATEWAY_IP="<your-gateway-ip>"

# Frontend health
curl -I http://$GATEWAY_IP/

# Backend health
curl http://$GATEWAY_IP/actuator/health

# Expected output: {"status":"UP"}
```

#### 3. Test API Endpoints (2 min)
```bash
# Test GET endpoint
curl http://$GATEWAY_IP/api/ingredients | jq

# Test POST endpoint (add to cart)
curl -X POST http://$GATEWAY_IP/api/cart/items \
  -H "Content-Type: application/json" \
  -d '{"sessionId":"test-123","ingredientId":1,"quantity":2}' | jq

# Verify cart
curl http://$GATEWAY_IP/api/cart/test-123 | jq
```

#### 4. Test UI in Browser (2 min)
1. Open `http://<GATEWAY_IP>/` in browser
2. Click on ingredient categories
3. Add items to burger
4. Open cart and verify items appear
5. Try placing an order

#### 5. Check Application Gateway Health (1 min)
```bash
az network application-gateway show-backend-health \
  --name naser-burger-builder-appgw \
  --resource-group naser-burger-builder-rg \
  --query "backendAddressPools[].backendHttpSettingsCollection[].servers[].health"

# Expected output: All backends showing "Healthy"
```

#### 6. View Logs (1 min)
```bash
# Backend logs
az containerapp logs show \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --tail 50

# Frontend logs
az containerapp logs show \
  --name frontend-app \
  --resource-group naser-burger-builder-rg \
  --tail 50
```

### Expected Results
- ✅ All Container Apps in "Running" state
- ✅ Health endpoints return HTTP 200
- ✅ API returns valid JSON responses
- ✅ UI loads and is interactive
- ✅ Application Gateway shows all backends "Healthy"
- ✅ No errors in container logs

---

## 🔒 Security Features

- **Network Isolation**: Container apps behind Application Gateway
- **Private Database**: Azure SQL with private endpoint (no public access)
- **CORS Protection**: Backend only accepts configured origins
- **Auto-scaling**: 1-10 instances based on load
- **Health Monitoring**: Automatic health checks and failover
- **Code Scanning**: SonarCloud security analysis on every deploy

---

## 📊 Monitoring & Logs

### View Container Logs
```bash
# Backend logs
az containerapp logs show \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --follow

# Frontend logs
az containerapp logs show \
  --name frontend-app \
  --resource-group naser-burger-builder-rg \
  --follow
```

### View Application Gateway Health
```bash
az network application-gateway show-backend-health \
  --name naser-burger-builder-appgw \
  --resource-group naser-burger-builder-rg
```

### Access Log Analytics
```bash
az monitor log-analytics workspace show \
  --workspace-name naser-burger-builder-log-analytics \
  --resource-group naser-burger-builder-rg
```

---

## 🧪 Testing

### Backend Tests
```bash
cd backend

# Run all tests
mvn test

# Run with coverage
mvn clean verify

# View coverage report
open target/site/jacoco/index.html
```

### Frontend Tests
```bash
cd frontend

# Run tests
npm run test

# Run with coverage
npm run test:coverage

# View coverage report
open coverage/index.html
```

### Quality Metrics (from SonarCloud)
- **Bugs**: 0 tolerance policy
- **Vulnerabilities**: Security issues detected and fixed
- **Code Coverage**: Target >70%
- **Code Smells**: Maintainability issues tracked
- **Duplication**: <3% code duplication
- **Dashboard**: View detailed reports at https://sonarcloud.io

---

## 🛠️ Manual Deployment (Without GitHub Actions)

### Build Docker Images Locally
```bash
# Build frontend
cd frontend
docker build -t your-dockerhub/burger-builder-frontend:latest .
docker push your-dockerhub/burger-builder-frontend:latest

# Build backend
cd backend
docker build -t your-dockerhub/burger-builder-backend:latest .
docker push your-dockerhub/burger-builder-backend:latest
```

### Deploy with Terraform
```bash
cd terraform

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Deploy
terraform apply

# Get outputs
terraform output
```

---

## 💥 Destroy Infrastructure

To avoid ongoing Azure costs after testing:

### Option 1: Via GitHub Actions
1. Go to **Actions** → **Deploy workflow**
2. Click **"Run workflow"**
3. Select action: `destroy`
4. Confirm

### Option 2: Via Terraform CLI
```bash
cd terraform
terraform destroy
```

This removes **all Azure resources** created by Terraform.

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check backend logs
docker-compose logs backend

# Common issues:
# - Database not ready: Wait 30s for PostgreSQL to initialize
# - Port conflict: Kill process on port 8080
# - Wrong credentials: Check environment.env file
```

### Frontend can't connect to backend
```bash
# Check CORS settings in backend
# Verify VITE_API_BASE_URL in frontend/.env
# Ensure backend is running: curl http://localhost:8080/actuator/health
```

### Deployment fails
```bash
# Check GitHub Actions logs
# Verify all 5 secrets are configured correctly
# Ensure Azure service principal has Contributor role
# Check Docker Hub token has push permissions
```

### Application Gateway returns 502
```bash
# Container apps may still be starting (wait 2-3 min)
# Check backend health: curl http://<GATEWAY_IP>/actuator/health
# View container logs in Azure Portal
```

---

## 📚 Tech Stack Details

### Frontend
- **React** 19.1.1 - UI framework
- **TypeScript** 5.8.3 - Type safety
- **Vite** 7.1.7 - Build tool
- **React Router** 7.9.3 - Routing
- **Axios** 1.12.2 - HTTP client
- **Vitest** - Testing framework
- **Nginx** - Production web server

### Backend
- **Spring Boot** 3.2.0 - Application framework
- **Java** 21 - Programming language
- **Maven** - Build tool
- **Spring Data JPA** - Database access
- **PostgreSQL** - Development database
- **Azure SQL** - Production database
- **Lombok** - Boilerplate reduction
- **JaCoCo** - Code coverage

### Infrastructure
- **Azure Container Apps** - Serverless containers
- **Application Gateway** - Load balancer
- **Azure SQL Database** - Managed database
- **Virtual Network** - Network isolation
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD pipeline
- **SonarCloud** - Code quality analysis

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

**Code Quality**: All PRs must pass SonarCloud quality gates.

---

## 📄 License

This project is part of a capstone project for educational purposes.

---

## 🆘 Need Help?

- **Deployment Issues**: Check GitHub Actions logs in the Actions tab
- **Infrastructure Issues**: Review Terraform outputs and Azure Portal
- **Code Issues**: Run tests locally and check SonarCloud reports at https://sonarcloud.io
- **Database Issues**: Verify connection strings and private endpoint configuration

---

## ✅ Quick Reference Commands

```bash
# Local development
cd backend && docker-compose up --build     # Start backend + database
cd frontend && npm run dev                  # Start frontend

# Build for production
cd backend && mvn clean package             # Build backend JAR
cd frontend && npm run build                # Build frontend assets

# Run tests
cd backend && mvn clean verify              # Backend tests + coverage
cd frontend && npm run test:coverage        # Frontend tests + coverage

# Deploy to Azure
# Push code → GitHub Actions → Deploy workflow → Wait 15 min → Done!

# Destroy infrastructure
# GitHub Actions → Deploy workflow → Select "destroy" → Confirm
```

**🎉 That's it! Your burger builder is ready to deploy!**
