provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  location = "West Europe"
}

resource "azurerm_resource_group" "group" {
  name     = "test-rg-actions"
  location = local.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.group.name
}

resource "azurerm_subnet" "snet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = [
    "Microsoft.AzureCosmosDB"
  ]
}
