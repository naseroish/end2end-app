# Random suffix for globally unique storage account name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${var.name}${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  
  blob_properties {
    versioning_enabled = var.versioning_enabled
  }
  
  tags = var.tags
}

# Storage Container
resource "azurerm_storage_container" "main" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = var.container_access_type
}
