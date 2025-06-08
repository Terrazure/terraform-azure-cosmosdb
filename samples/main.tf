module "cosmosdb" {
  source = "../"

  location            = local.location
  resource_group_name = azurerm_resource_group.group.name
  workload_name       = "primary-db"

  authorized_ips_or_cidr_blocks = ["103.59.72.25"]
  authorized_vnet_subnet_ids    = [azurerm_subnet.snet.id]
  azure_defender_enabled        = true

  backup = {
    type                = "Periodic"
    interval_in_minutes = 60 * 4 # 4 hours
    retention_in_hours  = 10
  }

  consistency_policy = {
    level                   = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100001
  }

  failover_locations = {
    eastus = {
      location       = "eastus2"
      #zone_redundant = true #Commenting due to the Azure service unavailability
    },
    westus = {
      location = "westus"
    },
  }

  # Various RBAC roles assignment as per requirement
  account_contributor_object_ids = [data.azurerm_client_config.current.object_id]
  operator_object_ids            = [data.azurerm_client_config.current.object_id]
}
