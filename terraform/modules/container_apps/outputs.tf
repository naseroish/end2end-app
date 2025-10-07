output "id" {
  description = "ID of the Container App"
  value       = azurerm_container_app.app.id
}

output "name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.app.name
}

output "fqdn" {
  description = "FQDN of the Container App"
  value       = var.ingress_enabled ? azurerm_container_app.app.ingress[0].fqdn : null
}

output "latest_revision_fqdn" {
  description = "Latest revision FQDN"
  value       = var.ingress_enabled ? azurerm_container_app.app.latest_revision_fqdn : null
}
