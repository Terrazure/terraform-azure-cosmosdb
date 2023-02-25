/**
 * Azure CosmosDB Account
 */

resource "azurerm_cosmosdb_account" "db" {
  name                            = module.naming.cosmosdb_account.value
  location                        = var.location
  resource_group_name             = var.resource_group_name
  offer_type                      = "Standard"
  kind                            = var.kind
  mongo_server_version            = var.kind == "MongoDB" ? var.mongo_server_version : null
  public_network_access_enabled   = false
  enable_automatic_failover       = true
  enable_multiple_write_locations = true
  default_identity_type           = var.customer_managed_keys.cmk_enabled ? "UserAssignedIdentity=${var.customer_managed_keys.user_managed_identity_id}" : null
  key_vault_key_id                = var.customer_managed_keys.cmk_enabled ? var.customer_managed_keys.kvt_key_versionless_id : null

  access_key_metadata_writes_enabled = false
  ip_range_filter                    = join(",", var.authorized_ips_or_cidr_blocks)
  is_virtual_network_filter_enabled  = length(var.authorized_vnet_subnet_ids) > 0 ? true : null

  dynamic "virtual_network_rule" {
    for_each = var.authorized_vnet_subnet_ids != null ? toset(var.authorized_vnet_subnet_ids) : []
    content {
      id = virtual_network_rule.value
    }
  }

  consistency_policy {
    consistency_level       = var.consistency_policy.level
    max_interval_in_seconds = var.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = var.consistency_policy.max_staleness_prefix
  }

  dynamic "backup" {
    for_each = var.backup != null ? ["enabled"] : []
    content {
      type                = local.backup.type
      interval_in_minutes = local.backup.interval_in_minutes
      retention_in_hours  = local.backup.retention_in_hours
    }
  }

  dynamic "capabilities" {
    for_each = toset(var.capabilities)
    content {
      name = capabilities.key
    }
  }

  dynamic "geo_location" {
    for_each = var.failover_locations != null ? var.failover_locations : local.default_failover_locations
    content {
      location          = geo_location.value.location
      zone_redundant    = lookup(geo_location.value, "zone_redundant", false)
      failover_priority = var.failover_locations != null ? index(values(var.failover_locations), geo_location.value) : 0
    }
  }

  dynamic "identity" {
    for_each = var.customer_managed_keys.cmk_enabled ? ["enabled"] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.customer_managed_keys.user_managed_identity_id]
    }
  }


  tags = var.tags
}

# Enable optional ATP for the Cosmos DB
resource "azurerm_advanced_threat_protection" "this" {
  count = var.azure_defender_enabled && var.kind != "MongoDB" ? 1 : 0 # Advanced threat protection not supported for MongoDB

  target_resource_id = azurerm_cosmosdb_account.db.id
  enabled            = true
}
