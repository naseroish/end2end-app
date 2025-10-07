variable "name" {
  description = "Name of the Container App Environment"
  type        = string
}

variable "location" {
  description = "Azure region for the environment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "Subnet ID for Container App infrastructure"
  type        = string
}

variable "internal_load_balancer_enabled" {
  description = "Whether to enable internal load balancer"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
