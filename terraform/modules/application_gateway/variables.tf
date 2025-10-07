variable "name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "public_ip_id" {
  description = "ID of the public IP address to use for Application Gateway"
  type        = string
}

variable "sku" {
  description = "SKU configuration for Application Gateway"
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
}

variable "frontend_fqdn" {
  description = "FQDN of the frontend container app"
  type        = string
}

variable "backend_fqdn" {
  description = "FQDN of the backend container app"
  type        = string
}

variable "frontend_health_path" {
  description = "Health check path for frontend"
  type        = string
  default     = "/"
}

variable "backend_health_path" {
  description = "Health check path for backend"
  type        = string
  default     = "/actuator/health"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
