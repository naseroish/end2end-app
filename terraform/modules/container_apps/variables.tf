variable "name" {
  description = "Name of the Container App"
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the Container App Environment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "revision_mode" {
  description = "Revision mode for the container app"
  type        = string
  default     = "Single"
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "cpu" {
  description = "CPU allocation"
  type        = number
}

variable "memory" {
  description = "Memory allocation"
  type        = string
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 10
}

variable "env_vars" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "ingress_enabled" {
  description = "Whether to enable ingress"
  type        = bool
  default     = true
}

variable "allow_insecure_connections" {
  description = "Allow insecure HTTP connections"
  type        = bool
  default     = true
}

variable "external_enabled" {
  description = "Enable external ingress"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Target port for ingress"
  type        = number
}

variable "ip_security_restrictions" {
  description = "IP security restrictions for ingress"
  type = list(object({
    name             = string
    description      = string
    action           = string
    ip_address_range = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
