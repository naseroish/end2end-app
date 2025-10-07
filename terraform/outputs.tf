# ============================================
# APPLICATION GATEWAY OUTPUTS (MAIN ACCESS)
# ============================================

output "app_gateway_public_ip" {
  description = "Public IP address - USE THIS TO ACCESS YOUR APP"
  value       = module.application_gateway.public_ip_address
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = module.application_gateway.frontend_url
}

output "backend_api_url" {
  description = "Backend API URL"
  value       = module.application_gateway.backend_url
}

output "health_check_url" {
  description = "Backend health check URL"
  value       = module.application_gateway.health_url
}

# ============================================
# INFRASTRUCTURE OUTPUTS
# ============================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.resource_group.name
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.sql_server.server_name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = module.sql_server.database_name
}

output "storage_account_name" {
  description = "Name of the Storage Account for Terraform state"
  value       = module.storage_account.name
}

# ============================================
# ACCESS INSTRUCTIONS
# ============================================

output "access_instructions" {
  description = "How to access your application"
  value = <<-EOT
  
  🎉 Deployment Complete! Access your Burger Builder application:
  
  📱 Frontend: ${module.application_gateway.frontend_url}
  🔌 Backend API: ${module.application_gateway.backend_url}
  ❤️  Health Check: ${module.application_gateway.health_url}
  
  All traffic goes through Application Gateway (Container Apps are not directly accessible).
  
  EOT
}
