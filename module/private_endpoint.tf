resource "azurerm_private_endpoint" "private_endpoint" {
  count = length(var.private_endpoint)

  name                = "${module.naming.private_endpoint.name}-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint[count.index]

  private_service_connection {
    name                           = "${module.naming.private_service_connection.name}-${count.index + 1}"
    private_connection_resource_id = azurerm_cosmosdb_account.db.id
    subresource_names              = [var.kind == "MongoDB" ? "MongoDB" : "Sql"]
    is_manual_connection           = false
  }
}
