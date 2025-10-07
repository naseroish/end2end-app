output "id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}
