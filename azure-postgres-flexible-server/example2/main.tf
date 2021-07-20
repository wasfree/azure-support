provider "azurerm" {
  features {}
}

locals {
  firewall_rules = {
    fw1 = {
      start_ip_address = "127.0.0.1"
      end_ip_address   = "127.0.0.1"
    },
    fw2 = {
      start_ip_address = "127.0.0.2"
      end_ip_address   = "127.0.0.2"
    },
    fw3 = {
      start_ip_address = "127.0.0.3"
      end_ip_address   = "127.0.0.3"
    }
  }
  configurations = {
    "connection_throttle.enable" = "on"
    "backslash_quote"            = "on"
    "wal_compression"            = "on"
  }
}

resource "random_password" "example" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_resource_group" "example" {
  name     = "example2-resources"
  location = "West Europe"
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                   = "example2-flexible-server"
  resource_group_name    = azurerm_resource_group.example.name
  location               = azurerm_resource_group.example.location
  version                = "12"
  administrator_login    = "psqladminun"
  administrator_password = random_password.example.result
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  for_each         = local.firewall_rules
  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.example.id
  start_ip_address = each.value["start_ip_address"]
  end_ip_address   = each.value["end_ip_address"]
}

resource "azurerm_postgresql_flexible_server_configuration" "example" {
  for_each  = local.configurations
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.example.id
  value     = each.value

  depends_on = [
    azurerm_postgresql_flexible_server_firewall_rule.example
  ]
}