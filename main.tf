terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.52.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
  prefix = "mc-server"
}

resource "azurerm_resource_group" "mc" {
  name     = "${local.prefix}-rg"
  location = var.location
}

resource "azurerm_storage_account" "mc" {
  name     = "${replace(local.prefix, "-", "")}sa"
  location = var.location

  resource_group_name      = azurerm_resource_group.mc.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "mc" {
  for_each = { for key, container in var.containers : key => container }

  name                 = "${each.key}-share"
  storage_account_name = azurerm_storage_account.mc.name
  quota                = 50
}

resource "azurerm_container_group" "mc" {
  name                = "${local.prefix}-continst"
  location            = var.location
  resource_group_name = azurerm_resource_group.mc.name

  ip_address_type = "public"
  dns_name_label  = "${local.prefix}s-bedrock"
  os_type         = "Linux"

  dynamic "container" {
    for_each = var.containers
    content {
      name   = container.key
      image  = "itzg/minecraft-bedrock-server"
      cpu    = "0.5"
      memory = "1.5"

      environment_variables = merge({
        SERVER_NAME    = container.key
        EULA           = "TRUE"
        SERVER_PORT    = container.value["port"]
        SERVER_PORT_V6 = container.value["port"] + 1
      }, container.value["environment"])

      ports {
        port     = container.value["port"]
        protocol = "UDP"
      }

      volume {
        name       = "${container.key}-volume"
        mount_path = "/data"

        storage_account_name = azurerm_storage_account.mc.name
        storage_account_key  = azurerm_storage_account.mc.primary_access_key
        share_name           = "${container.key}-share"
      }
    }
  }

  tags = {
    environment = "testing"
  }
}
