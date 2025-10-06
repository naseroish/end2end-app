# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.resource_group.name
}

# Network Outputs
output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.virtual_network.name
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = module.subnets["app_subnet"].subnet.id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = module.subnets["db_subnet"].subnet.id
}

# Container Apps Outputs
output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.main.id
}

output "container_app_environment_default_domain" {
  description = "Default domain of the Container App Environment"
  value       = azurerm_container_app_environment.main.default_domain
}

output "frontend_app_url" {
  description = "URL of the frontend application"
  value       = "https://${azurerm_container_app.apps["frontend"].ingress[0].fqdn}"
}

output "backend_app_url" {
  description = "URL of the backend application"  
  value       = "https://${azurerm_container_app.apps["backend"].ingress[0].fqdn}"
}

output "frontend_fqdn" {
  description = "FQDN of the frontend application"
  value       = azurerm_container_app.apps["frontend"].ingress[0].fqdn
}

output "backend_fqdn" {
  description = "FQDN of the backend application"
  value       = azurerm_container_app.apps["backend"].ingress[0].fqdn
}

output "container_apps_info" {
  description = "Information about all container apps"
  value = {
    for key, app in azurerm_container_app.apps : key => {
      name        = app.name
      resource_id = app.id
      fqdn        = app.ingress[0].fqdn
      url         = "https://${app.ingress[0].fqdn}"
    }
  }
}

# Environment variables for cross-app communication
output "app_communication_info" {
  description = "Communication information between apps"
  value = {
    frontend_api_endpoint = "https://${azurerm_container_app.apps["backend"].ingress[0].fqdn}"
    backend_cors_origin   = "https://${azurerm_container_app.apps["frontend"].ingress[0].fqdn}"
  }
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

# Database Outputs
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_server_private_fqdn" {
  description = "Private FQDN of the SQL Server (via private endpoint)"
  value       = "${azurerm_mssql_server.main.name}.privatelink.database.windows.net"
}

output "sql_connection_string" {
  description = "SQL Server connection details for backend"
  value = {
    host     = "${azurerm_mssql_server.main.name}.privatelink.database.windows.net"
    port     = "1433"
    database = azurerm_mssql_database.main.name
    username = var.sql_admin_username
  }
  sensitive = false
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "sql_server_resource_id" {
  description = "Resource ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

# Storage Account Outputs
output "storage_account_name" {
  description = "Name of the Storage Account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  description = "Name of the Storage Container for Terraform state"
  value       = azurerm_storage_container.tfstate.name
}

# Application Gateway Outputs
output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway - USE THIS TO ACCESS YOUR APP"
  value       = azurerm_public_ip.appgw.ip_address
}

output "app_gateway_url" {
  description = "URL to access the application through Application Gateway"
  value       = "http://${azurerm_public_ip.appgw.ip_address}"
}

output "app_gateway_api_url" {
  description = "URL to access the backend API through Application Gateway"
  value       = "http://${azurerm_public_ip.appgw.ip_address}/api"
}

output "app_gateway_health_url" {
  description = "URL to check backend health through Application Gateway"
  value       = "http://${azurerm_public_ip.appgw.ip_address}/actuator/health"
}

output "app_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "app_gateway_id" {
  description = "Resource ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

# Access Instructions
output "access_instructions" {
  description = "How to access your application"
  value = <<-EOT
  
  🎉 Deployment Complete! Access your Burger Builder application:
  
  📱 Frontend: http://${azurerm_public_ip.appgw.ip_address}/
  🔌 Backend API: http://${azurerm_public_ip.appgw.ip_address}/api/
  ❤️  Health Check: http://${azurerm_public_ip.appgw.ip_address}/actuator/health
  
  All requests are routed through the Application Gateway for security and load balancing.
  See terraform/APPLICATION-GATEWAY-ROUTING.md for detailed routing information.
  
  EOT
}