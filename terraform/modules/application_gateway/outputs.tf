output "id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw.ip_address
}

output "public_ip_id" {
  description = "ID of the public IP"
  value       = azurerm_public_ip.appgw.id
}

output "frontend_url" {
  description = "URL to access the frontend application"
  value       = "http://${azurerm_public_ip.appgw.ip_address}"
}

output "backend_url" {
  description = "URL to access the backend API"
  value       = "http://${azurerm_public_ip.appgw.ip_address}/api"
}

output "health_url" {
  description = "URL for backend health check"
  value       = "http://${azurerm_public_ip.appgw.ip_address}/actuator/health"
}
