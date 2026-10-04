terraform {
  backend "azurerm" {
    resource_group_name  = "sotetel-platform-rg"
    storage_account_name = "sotetelplatformtfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}