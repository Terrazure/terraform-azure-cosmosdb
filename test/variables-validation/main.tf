provider "azurerm" {
  features {}
}

locals {
  location    = "westeurope"
}

resource "random_string" "workload_name" {
  length  = 9
  special = false
  upper   = false
  numeric = false
}

data "azurerm_client_config" "current" {}

variable "kind" {
  type    = string
  default = "GlobalDocumentDB"
}
variable "capabilities" {
  type    = list(string)
  default = []
}
variable "zone_redundancy_enabled" {
  type    = bool
  default = true
}
variable "backup" {
  type = object({
    type                = string
    interval_in_minutes = number
    retention_in_hours  = number
  })
  default = null
}

variable "consistency_policy" {
  type = object({
    level                   = string
    max_interval_in_seconds = number
    max_staleness_prefix    = number
  })
  default = {
    level                   = "BoundedStaleness"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
}

resource "azurerm_resource_group" "group" {
  name     = "ci-cosmosdb-basic-rg-${random_string.workload_name.result}"
  location = local.location
}

module "cosmosdb" {
  source = "../.."

  location                = local.location
  resource_group_name     = azurerm_resource_group.group.name
  workload_name           = random_string.workload_name.result
  kind                    = var.kind
  capabilities            = var.capabilities
  zone_redundancy_enabled = var.zone_redundancy_enabled
  backup                  = var.backup
  consistency_policy      = var.consistency_policy
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