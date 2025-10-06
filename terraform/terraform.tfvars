
subscription_id = "4421688c-0a8d-4588-8dd0-338c5271d0af"
resource_group_name = "naser-burger-builder-rg"
vnet_name           = "naser-burger-builder-vnet"
location            = "South Africa North"

address_space = ["10.0.0.0/16"]

subnet = {
  app_subnet = {
    address_space = ["10.0.2.0/23"]
  }
  db_subnet = {
    address_space = ["10.0.4.0/24"]
  }
  appgw_subnet = {
    address_space = ["10.0.1.0/24"]
  }
}

# Container Apps Configuration
log_analytics_workspace_name = "naser-burger-builder-log-analytics"
container_app_environment_name = "naser-burger-builder-app-env"

container_apps = {
  frontend = {
    image            = "docker.io/uo3d/burger-builder-frontend:latest"
    cpu              = 0.25
    memory           = "0.5Gi"
    target_port      = 80  # Nginx serves on port 80
    external_enabled = true
    min_replicas     = 1
    max_replicas     = 10
    env_vars = {
      # Frontend will use VITE_API_BASE_URL to connect to backend
      # This will be set dynamically after backend FQDN is known
    }
  }
  backend = {
    image            = "docker.io/uo3d/burger-builder-backend:latest"
    cpu              = 0.5
    memory           = "1Gi"
    target_port      = 8080  # Spring Boot default port
    external_enabled = true
    min_replicas     = 1
    max_replicas     = 10
    env_vars = {
      SPRING_PROFILES_ACTIVE = "azure"
      SERVER_PORT            = "8080"
      # Database connection will be configured via secrets
      # CORS will be configured to allow frontend domain
    }
  }
}

tags = {
  Environment = "Production"
  Project     = "Burger-Builder"
  Owner       = "Naser"
}

# Application Gateway Configuration
app_gateway_name = "naser-burger-builder-appgw"
app_gateway_sku = {
  name     = "Standard_v2"
  tier     = "Standard_v2"
  capacity = 2
}

# Database Configuration
sql_server_name     = "naser-burger-builder-sql"
sql_database_name   = "burgerbuilder"
sql_admin_username  = "sqladmin"
sql_admin_password  = "BurgerAdmin@2025!"  # In production, use Azure Key Vault or GitHub Secrets