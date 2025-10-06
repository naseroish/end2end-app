terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}



module "resource_group" {
  source   = "./azurerm_resource_group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "./azurerm_virtual_network"
  name                = var.vnet_name
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

module "subnets" {
  source              = "./azurerm_subnets"
  for_each            = var.subnet
  name                = each.key
  resource_group_name = module.resource_group.resource_group.name
  vnet_name           = module.vnet.virtual_network.name
  address_prefixes    = each.value.address_space
}

# Log Analytics Workspace for Container App Environment
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Container App Environment with VNet Integration
resource "azurerm_container_app_environment" "main" {
  name                           = var.container_app_environment_name
  location                       = var.location
  resource_group_name            = module.resource_group.resource_group.name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id       = module.subnets["app_subnet"].subnet.id
  internal_load_balancer_enabled = false
  tags                           = var.tags
}

# Container Apps - Using for_each for dynamic deployment
resource "azurerm_container_app" "apps" {
  for_each                     = var.container_apps
  name                         = "${each.key}-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = module.resource_group.resource_group.name
  revision_mode                = "Single"
  
  template {
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas
    
    container {
      name   = each.key
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory
      
      # Base environment variables from tfvars
      dynamic "env" {
        for_each = each.value.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
      
      # Backend-specific environment variables
      dynamic "env" {
        for_each = each.key == "backend" ? {
          DB_HOST               = "${azurerm_mssql_server.main.name}.privatelink.database.windows.net"
          DB_PORT               = "1433"
          DB_NAME               = azurerm_mssql_database.main.name
          DB_USERNAME           = var.sql_admin_username
          DB_PASSWORD           = var.sql_admin_password
          DB_DRIVER             = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
          CORS_ALLOWED_ORIGINS  = "http://${azurerm_public_ip.appgw.ip_address}"
        } : {}
        
        content {
          name  = env.key
          value = env.value
        }
      }
      
      # Frontend-specific environment variables
      # Frontend will call Application Gateway public IP for API requests
      # Note: This requires the App Gateway to be created first, or update after deployment
      dynamic "env" {
        for_each = each.key == "frontend" ? {
          VITE_API_BASE_URL = "http://${azurerm_public_ip.appgw.ip_address}"
        } : {}
        
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }
  
  ingress {
    allow_insecure_connections = true
    external_enabled          = each.value.external_enabled
    target_port              = each.value.target_port
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    
    # IP Restrictions - Only allow traffic from Application Gateway
    # When action=Allow is used, all other IPs are implicitly denied
    ip_security_restriction {
      name             = "AllowAppGatewayOnly"
      description      = "Only allow traffic from Application Gateway public IP"
      action           = "Allow"
      ip_address_range = azurerm_public_ip.appgw.ip_address
    }
  }
  
  tags = var.tags
  
  # Ensure SQL database is ready before deploying any container apps
  depends_on = [
    azurerm_mssql_database.main,
    azurerm_private_endpoint.sql
  ]
}

# Azure SQL Server (direct azurerm resource)
resource "azurerm_mssql_server" "main" {
  name                         = "${var.sql_server_name}-${random_string.suffix.result}"
  resource_group_name          = module.resource_group.resource_group.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  public_network_access_enabled = false
  
  tags = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name         = var.sql_database_name
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2  # Basic tier supports up to 2GB
  sku_name     = "Basic"
  
  tags = var.tags
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql" {
  name                = "${var.sql_server_name}-${random_string.suffix.result}-private-endpoint"
  location            = var.location
  resource_group_name = module.resource_group.resource_group.name
  subnet_id           = module.subnets["db_subnet"].subnet.id

  private_service_connection {
    name                           = "${var.sql_server_name}-${random_string.suffix.result}-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }

  tags = var.tags
}

# Private DNS Zone for SQL Server (still needed for the module)
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = module.resource_group.resource_group.name
  tags                = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-dns-link"
  resource_group_name   = module.resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = module.vnet.virtual_network.id
  registration_enabled  = false
  tags                  = var.tags
}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "${var.app_gateway_name}-pip"
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = var.app_gateway_name
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  tags                = var.tags

  sku {
    name     = var.app_gateway_sku.name
    tier     = var.app_gateway_sku.tier
    capacity = var.app_gateway_sku.capacity
  }

  gateway_ip_configuration {
    name      = "${var.app_gateway_name}-ip-config"
    subnet_id = module.subnets["appgw_subnet"].subnet.id
  }

  # Frontend Configuration
  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${var.app_gateway_name}-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # Backend Address Pools
  backend_address_pool {
    name  = "frontend-backend-pool"
    fqdns = [azurerm_container_app.apps["frontend"].ingress[0].fqdn]
  }

  backend_address_pool {
    name  = "backend-backend-pool"
    fqdns = [azurerm_container_app.apps["backend"].ingress[0].fqdn]
  }

  # Backend HTTP Settings for Frontend
  backend_http_settings {
    name                  = "frontend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
    probe_name            = "frontend-health-probe"
    pick_host_name_from_backend_address = true
  }

  # Backend HTTP Settings for Backend API
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
    probe_name            = "backend-health-probe"
    pick_host_name_from_backend_address = true
  }

  # Rewrite Rule Set to strip /api prefix
  rewrite_rule_set {
    name = "api-rewrite-rules"
    
    rewrite_rule {
      name          = "strip-api-prefix"
      rule_sequence = 100
      
      condition {
        variable    = "var_uri_path"
        pattern     = "^/api/(.*)"
        ignore_case = true
      }
      
      url {
        path = "/{var_uri_path_1}"
      }
    }
  }

  # Health Probes
  probe {
    name                                      = "frontend-health-probe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                                      = "backend-health-probe"
    protocol                                  = "Https"
    path                                      = "/actuator/health"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  # HTTP Listener (single listener for all traffic)
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "${var.app_gateway_name}-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # URL Path Maps for path-based routing
  url_path_map {
    name                               = "path-based-routing"
    default_backend_address_pool_name  = "frontend-backend-pool"
    default_backend_http_settings_name = "frontend-http-settings"

    # Route /api/* to backend
    path_rule {
      name                       = "api-routing"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-backend-pool"
      backend_http_settings_name = "backend-http-settings"
    }

    # Route /actuator/* to backend (for health checks)
    path_rule {
      name                       = "actuator-routing"
      paths                      = ["/actuator/*"]
      backend_address_pool_name  = "backend-backend-pool"
      backend_http_settings_name = "backend-http-settings"
    }
  }

  # Routing Rule with Path-Based Routing
  request_routing_rule {
    name                       = "path-based-routing-rule"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "http-listener"
    url_path_map_name          = "path-based-routing"
    priority                   = 100
  }

  depends_on = [
    azurerm_container_app.apps
  ]
}

# Storage Account for Terraform State (optional - for remote backend)
resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_string.suffix.result}"
  resource_group_name      = module.resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  blob_properties {
    versioning_enabled = true
  }
  
  tags = var.tags
}

# Storage Container for Terraform State
resource "azurerm_storage_container" "tfstate" {
  name                 = "tfstate"
  storage_account_id   = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
