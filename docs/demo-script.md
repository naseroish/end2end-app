# 🎬 Burger Builder - Demo Script (3-5 minutes)

## 🎯 Demo Objectives
- Showcase full-stack application deployment on Azure
- Demonstrate CI/CD pipeline with GitHub Actions
- Highlight Infrastructure as Code with Terraform
- Show code quality integration with SonarCloud

---

## 📝 Demo Flow (5 minutes)

### **Minute 1: Introduction & Architecture** (60 sec)

**[Show Architecture Diagram]**

> "Today I'm presenting Burger Builder - a production-ready full-stack application demonstrating modern DevOps practices on Azure."

**Key Points**:
- React 19 + TypeScript frontend
- Spring Boot 3.2 + Java 21 backend
- Azure Container Apps (serverless containers)
- Application Gateway for load balancing
- Azure SQL Database with private endpoint
- All infrastructure managed via Terraform

---

### **Minute 2: Code Quality & CI/CD Pipeline** (60 sec)

**[Open GitHub Actions Workflow]**
- Navigate to: `https://github.com/naseroish/end2end-app/actions`

> "The deployment is fully automated through GitHub Actions with integrated quality gates."

**Demonstrate Workflow**:
1. Click on latest workflow run
2. Show 4 stages:
   - ✅ **SonarCloud Analysis** (Backend + Frontend)
   - ✅ **Build & Push Docker Images**
   - ✅ **Deploy Infrastructure (Terraform)**
   - ✅ **Health Checks & Verification**

**[Open SonarCloud Dashboard]**
- Navigate to: `https://sonarcloud.io/organizations/naseroish`
- Show quality metrics:
  - Zero bugs
  - No vulnerabilities
  - Code coverage >70%
  - Minimal code smells

> "Every deployment runs through SonarCloud quality gates to ensure code quality and security."

---

### **Minute 3: Live Application Demo** (90 sec)

**[Open Application in Browser]**
- Navigate to: `http://<APP_GATEWAY_IP>/`

**Demonstrate Features**:

1. **Build a Burger** (20 sec):
   - Click through ingredient categories (Protein, Vegetables, Condiments)
   - Add items: Beef Patty, Lettuce, Tomato, Cheese
   - Show real-time burger preview building up
   - Point out dynamic price calculation

2. **Cart Management** (20 sec):
   - Open cart view
   - Show added items with quantities
   - Update quantity (increase/decrease)
   - Show total price updates automatically
   - Remove an item to demonstrate cart management

3. **Order Placement** (20 sec):
   - Click "Checkout" or "Place Order"
   - Fill in customer information:
     - Name: "Demo User"
     - Address: "123 Azure Lane"
   - Submit order
   - Show order confirmation with order ID

4. **Order History** (15 sec):
   - Navigate to Order History page
   - Show placed order with status
   - Demonstrate order tracking

5. **API Testing** (15 sec):
   - Open new tab: `http://<APP_GATEWAY_IP>/api/ingredients`
   - Show JSON response with all ingredients
   - Demonstrate RESTful API working

---

### **Minute 4: Azure Infrastructure Tour** (60 sec)

**[Open Azure Portal]**
- Navigate to Resource Group: `naser-burger-builder-rg`

**Show Created Resources**:

1. **Container Apps** (15 sec):
   - Show `frontend-app` and `backend-app`
   - Point out auto-scaling configuration (1-10 replicas)
   - Show current running replicas

2. **Application Gateway** (15 sec):
   - Show public IP address
   - Explain path-based routing:
     - `/` → Frontend
     - `/api/*` → Backend
   - Show backend health: All healthy

3. **Azure SQL Database** (15 sec):
   - Show `burgerdb`
   - Highlight **private endpoint** (no public access)
   - Point out secure connectivity through VNet

4. **Networking** (15 sec):
   - Show Virtual Network with 3 subnets:
     - Container Apps subnet
     - Database subnet
     - Application Gateway subnet
   - Explain network isolation

---

### **Minute 5: Monitoring & Teardown** (60 sec)

**[Show Container Logs]** (20 sec)

**Option 1: Azure Portal**:
- Navigate to Backend Container App
- Click "Log Stream"
- Show real-time logs of API requests

**Option 2: Azure CLI**:
```bash
az containerapp logs show \
  --name backend-app \
  --resource-group naser-burger-builder-rg \
  --follow
```
- Show logs from recent order placement

**[Show Log Analytics]** (20 sec):
- Navigate to Log Analytics Workspace
- Show metrics dashboard
- Point out request counts, response times, errors

**[Demonstrate Infrastructure Teardown]** (20 sec):

> "One of the key advantages of Infrastructure as Code - we can destroy everything with one command."

**Option 1: GitHub Actions**:
- Go to Actions → Deploy workflow
- Run workflow with action: `destroy`
- Show confirmation

**Option 2: Terraform CLI**:
```bash
cd terraform
terraform destroy
```

> "This removes all Azure resources, preventing unnecessary costs when the environment isn't needed."

---

## 🎤 Talking Points & Highlights

### Key Technical Achievements
- ✅ **Fully Automated CI/CD**: Zero manual deployment steps
- ✅ **Infrastructure as Code**: 100% Terraform managed
- ✅ **Code Quality Gates**: SonarCloud integration prevents bad code
- ✅ **Secure Architecture**: Private database, network isolation
- ✅ **Production Ready**: Auto-scaling, health checks, monitoring
- ✅ **Cost Effective**: Serverless containers, pay-per-use

### DevOps Best Practices Demonstrated
1. **Version Control**: All code and infrastructure in Git
2. **Automated Testing**: Unit tests + code coverage
3. **Quality Gates**: SonarCloud prevents vulnerabilities
4. **Containerization**: Docker multi-stage builds
5. **IaC**: Terraform modules for reusability
6. **Monitoring**: Log Analytics + health checks
7. **Security**: Private endpoints, network isolation, secrets management

---

## 💡 Bonus: Q&A Preparation

### Expected Questions & Answers

**Q: How long does deployment take?**
> A: Approximately 15-20 minutes for full deployment. SonarCloud analysis takes 5 min, building images 5 min, and Terraform deployment 8-10 min.

**Q: What's the monthly cost?**
> A: Approximately $160-180 USD. Main costs are Application Gateway (~$70), Azure SQL (~$50), and Container Apps (~$40). Costs scale with usage due to serverless architecture.

**Q: How does auto-scaling work?**
> A: Container Apps scale from 1-10 replicas based on HTTP traffic. When requests increase, Azure automatically spins up new container instances. During low traffic, it scales down to 1 replica to save costs.

**Q: Why not use Kubernetes?**
> A: Azure Container Apps provides managed Kubernetes (built on KEDA) without the operational overhead. We get Kubernetes benefits (scaling, health checks) without managing clusters, nodes, or control planes.

**Q: How do you handle database migrations?**
> A: We use SQL scripts (`schema.sql`, `data.sql`) that run on application startup. Spring Boot's schema initialization handles database versioning. For production, we'd use Flyway or Liquibase for safer migrations.

**Q: What about high availability?**
> A: Application Gateway provides load balancing across multiple container replicas. Azure SQL has built-in geo-redundancy. Container Apps automatically replace failed instances. The architecture supports 99.95% SLA.

**Q: How do you manage secrets?**
> A: GitHub Secrets for CI/CD credentials. Azure Key Vault integration possible for enhanced security. Database passwords injected via Terraform variables and container environment variables.

**Q: Can this scale to production traffic?**
> A: Yes. Container Apps can scale to 30+ replicas per app. Application Gateway supports thousands of requests per second. Azure SQL can scale to higher tiers. The architecture is production-grade.

---

## 📊 Demo Checklist

### Pre-Demo Setup (15 min before)
- [ ] Ensure application is deployed and running
- [ ] Test application URL is accessible
- [ ] Clear browser cache and cookies
- [ ] Open required tabs:
  - [ ] GitHub Actions workflow
  - [ ] SonarCloud dashboard
  - [ ] Application URL
  - [ ] Azure Portal (logged in)
  - [ ] VS Code with project open
- [ ] Test API endpoints with curl/Postman
- [ ] Verify Application Gateway health
- [ ] Have terminal ready with Azure CLI logged in
- [ ] Prepare fallback: screenshots if live demo fails

### Backup Materials
- Screenshots of:
  - [ ] Architecture diagram
  - [ ] GitHub Actions successful run
  - [ ] SonarCloud quality report
  - [ ] Working application
  - [ ] Azure resources
  - [ ] Monitoring dashboard
- [ ] Video recording of working app (30 sec)

---

## 🎯 Success Criteria

### Audience Should Understand:
✅ Full-stack application architecture on Azure  
✅ CI/CD pipeline with automated quality checks  
✅ Infrastructure as Code benefits  
✅ Serverless container deployment  
✅ Cost-effective cloud architecture  
✅ Security best practices (private endpoints, network isolation)  

### Demonstrated Skills:
✅ Azure Container Apps & Application Gateway  
✅ Terraform infrastructure management  
✅ GitHub Actions CI/CD pipelines  
✅ Docker containerization  
✅ React + Spring Boot development  
✅ SonarCloud code quality integration  
✅ Azure SQL Database configuration  

---

## ⏱️ Time Management Tips

- **Running short?** Skip Order History and API demo. Focus on deployment pipeline.
- **Running long?** Skip detailed Azure resource tour. Just show resource group overview.
- **Live demo fails?** Have screenshots ready and explain architecture from diagram.
- **Questions during demo?** Defer to Q&A or answer briefly and continue.

---

**Demo Duration**: 3-5 minutes  
**Extended Version**: Up to 10 minutes with Q&A  
**Last Updated**: October 9, 2025
