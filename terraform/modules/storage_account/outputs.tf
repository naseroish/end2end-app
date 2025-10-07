output "id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.main.name
}

output "container_id" {
  description = "ID of the storage container"
  value       = azurerm_storage_container.main.id
}
