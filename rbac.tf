module "role_assignment" {
  source = "github.com/Terrazure/terraform-azure-rbac"

  role_mapping = [
    {
      role_definition_name = "DocumentDB Account Contributor"
      principal_ids        = var.account_contributor_object_ids
    },
    {
      role_definition_name = "Cosmos DB Account Reader Role"
      principal_ids        = var.account_reader_object_ids
    },
    {
      role_definition_name = "CosmosBackupOperator"
      principal_ids        = var.backup_operator_object_ids
    },
    {
      role_definition_name = "Cosmos DB Operator"
      principal_ids        = var.operator_object_ids
    },
  ]

  scope_id = azurerm_cosmosdb_account.db.id
}