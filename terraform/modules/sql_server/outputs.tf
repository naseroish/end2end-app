output "server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "server_private_fqdn" {
  description = "Private FQDN of the SQL Server"
  value       = "${azurerm_mssql_server.main.name}.privatelink.database.windows.net"
}

output "database_id" {
  description = "ID of the database"
  value       = azurerm_mssql_database.main.id
}

output "database_name" {
  description = "Name of the database"
  value       = azurerm_mssql_database.main.name
}

output "connection_info" {
  description = "Database connection information"
  value = {
    host     = "${azurerm_mssql_server.main.name}.privatelink.database.windows.net"
    port     = "1433"
    database = azurerm_mssql_database.main.name
    username = var.admin_username
  }
  sensitive = false
}
