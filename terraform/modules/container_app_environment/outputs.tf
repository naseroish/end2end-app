output "id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.main.id
}

output "default_domain" {
  description = "Default domain of the Container App Environment"
  value       = azurerm_container_app_environment.main.default_domain
}

output "name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.main.name
}
