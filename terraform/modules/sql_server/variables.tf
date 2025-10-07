variable "server_name" {
  description = "Name of the SQL Server (suffix will be added for uniqueness)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the SQL Server"
  type        = string
}

variable "server_version" {
  description = "Version of SQL Server"
  type        = string
  default     = "12.0"
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
}

variable "admin_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "collation" {
  description = "Database collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  description = "License type"
  type        = string
  default     = "LicenseIncluded"
}

variable "max_size_gb" {
  description = "Maximum database size in GB"
  type        = number
  default     = 2
}

variable "sku_name" {
  description = "SKU name for the database"
  type        = string
  default     = "Basic"
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "virtual_network_id" {
  description = "Virtual Network ID for DNS zone link"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
