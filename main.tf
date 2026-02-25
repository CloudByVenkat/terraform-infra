locals {
  common_tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${random_string.unique.result}"
  location = var.location
  tags     = local.common_tags
}

# Storage Account (secure configuration)
resource "azurerm_storage_account" "main" {
  name                     = lower("st${var.project_name}${var.environment}${random_string.unique.result}")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false

  tags = local.common_tags
}
# Random suffix for unique resource names
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}