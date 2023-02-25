output "id" {
  description = "The Cosmos DB Account ID."
  value       = azurerm_cosmosdb_account.db.id
}

output "name" {
  description = "The Cosmos DB Account name."
  value       = azurerm_cosmosdb_account.db.name
}

output "cosmosdb_endpoint" {
  description = "The endpoint used to connect to the CosmosDB account."
  value       = azurerm_cosmosdb_account.db.endpoint
}
