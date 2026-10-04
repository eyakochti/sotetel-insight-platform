terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "bootstrap" {
  name     = "sotetel-platform-rg"
  location = "swedencentral"

  tags = {
    projet = "sotetel"
    env    = "bootstrap"
    owner  = "eya"
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "sotetelplatformtfstate"
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = azurerm_resource_group.bootstrap.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    projet = "sotetel"
    env    = "bootstrap"
    owner  = "eya"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}