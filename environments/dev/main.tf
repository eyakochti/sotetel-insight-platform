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

resource "azurerm_resource_group" "main" {
  name     = "${local.prefix}-rg"
  location = "swedencentral"
  tags     = local.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "${local.prefix}-vnet-main"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "${local.prefix}-subnet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${local.prefix}-id-aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_virtual_network.main.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${local.prefix}-aks-main"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dns_prefix          = "${local.prefix}-aks"
  sku_tier            = "Free"

  default_node_pool {
    name           = "system"
    node_count     = 2
    vm_size        = "Standard_B2s_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.100.0.0/16"
    dns_service_ip = "10.100.0.10"
  }

  role_based_access_control_enabled = true

  tags = local.tags

  depends_on = [azurerm_role_assignment.aks_network]
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}