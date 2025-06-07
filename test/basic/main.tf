provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

locals {
  location = "West Europe"
}

resource "random_string" "workload_name" {
  length  = 9
  special = false
  upper   = false
  numeric = false
}

data "azurerm_client_config" "current" {}

variable "environment" { type = string }
variable "kind" { type = string }
variable "capabilities" { type = list(string) }
variable "consistency_policy" {
  type = object({
    level                   = string
    max_interval_in_seconds = number
    max_staleness_prefix    = number
  })
}

variable "failover_locations" {
  type = map(object({
    location       = string
    zone_redundant = bool
  }))
  default = null
}

variable "azure_defender_enabled" {
  type = bool
}

resource "azurerm_resource_group" "group" {
  name     = "ci-cosmosdb-basic-rg-${random_string.workload_name.result}"
  location = local.location
}

module "cosmosdb" {
  source = "../.."

  location               = local.location
  resource_group_name    = azurerm_resource_group.group.name
  workload_name          = random_string.workload_name.result
  kind                   = var.kind
  capabilities           = var.capabilities
  consistency_policy     = var.consistency_policy
  failover_locations     = var.failover_locations
  azure_defender_enabled = var.azure_defender_enabled
}

output "resource_group_name" {
  value = azurerm_resource_group.group.name
}

output "accountName" {
  value = module.cosmosdb.name
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}