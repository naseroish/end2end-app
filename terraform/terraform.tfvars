
resource_group_name = "fs-terraform-rg"
vnet_name           = "fs-terraform-vnet"
location            = "South Africa North"

address_space = ["10.0.0.0/16"]

subnet = {
  app_subnet = {
    address_space = ["10.0.2.0/23"]
  }
  db_subnet = {
    address_space = ["10.0.4.0/24"]
  }
}

# Container Apps Configuration
log_analytics_workspace_name = "ecommerce-log-analytics"
container_app_environment_name = "ecommerce-app-env"

container_apps = {
  frontend = {
    image            = "docker.io/uo3d/ecommerce-frontend:latest"  # Docker Hub public image
    cpu              = 0.25
    memory           = "0.5Gi"
    target_port      = 80  # Nginx default port
    external_enabled = true
    min_replicas     = 0  # Allow scale to zero
    max_replicas     = 10
    env_vars = {
      NODE_ENV = "production"
    }
  }
  backend = {
    image            = "docker.io/uo3d/ecommerce-backend:latest"  # Docker Hub public image
    cpu              = 0.5
    memory           = "1Gi"
    target_port      = 3001
    external_enabled = true  # Make backend external for easier testing
    min_replicas     = 0  # Allow scale to zero
    max_replicas     = 10
    env_vars = {
      PORT = "3001"
      NODE_ENV = "production"
    }
  }
}

tags = {
  Environment = "Development"
  Project     = "ECommerce-Three-Tier"
  Owner       = "Naser"
}

# Database Configuration
sql_server_name     = "ecommerce-sql-server"
sql_database_name   = "ecommerce-db"
sql_admin_username  = "sqladmin"
sql_admin_password  = "P@ssw0rd123!"  # In production, use Azure Key Vault or GitHub Secrets

# Azure Configuration
subscription_id = "80646857-9142-494b-90c5-32fea6acbc41"
