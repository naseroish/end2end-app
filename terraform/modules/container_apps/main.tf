resource "azurerm_container_app" "app" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  
  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    
    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory
      
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }
  
  dynamic "ingress" {
    for_each = var.ingress_enabled ? [1] : []
    content {
      allow_insecure_connections = var.allow_insecure_connections
      external_enabled          = var.external_enabled
      target_port              = var.target_port
      
      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
      
      dynamic "ip_security_restriction" {
        for_each = var.ip_security_restrictions
        content {
          name             = ip_security_restriction.value.name
          description      = ip_security_restriction.value.description
          action           = ip_security_restriction.value.action
          ip_address_range = ip_security_restriction.value.ip_address_range
        }
      }
    }
  }
  
  tags = var.tags
}
