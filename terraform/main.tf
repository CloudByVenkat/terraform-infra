# Day 22: Main Infrastructure Configuration for CI/CD

# Random suffix for unique resource names
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

# ═══════════════════════════════════════════════════════════════
# MODULE 1: Resource Group
# ═══════════════════════════════════════════════════════════════
module "resource_group" {
  source = "./modules/resource-group"
  
  project_name = var.project_name
  environment  = var.environment
  location     = var.location
  common_tags  = local.common_tags
}

# ═══════════════════════════════════════════════════════════════
# MODULE 2: Networking (VNet, Subnets)
# ═══════════════════════════════════════════════════════════════
module "networking" {
  source = "./modules/networking"
  
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  
  vnet_address_space = var.vnet_address_space
  subnets = {
    frontend = {
      address_prefix = cidrsubnet(var.vnet_address_space[0], 8, 1)
      delegation     = "Microsoft.Web/serverFarms"
    }
    backend = {
      address_prefix = cidrsubnet(var.vnet_address_space[0], 8, 2)
      delegation     = "Microsoft.Web/serverFarms"
    }
    database = {
      address_prefix = cidrsubnet(var.vnet_address_space[0], 8, 3)
      delegation     = null
    }
  }
  
  common_tags = local.common_tags
}

# ═══════════════════════════════════════════════════════════════
# MODULE 3: Key Vault with RBAC
# ═══════════════════════════════════════════════════════════════
module "key_vault" {
  source = "./modules/key-vault"
  
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  unique_suffix       = random_string.unique.result
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_id     = data.azurerm_client_config.current.object_id
  
  enable_purge_protection = var.environment == "production"
  network_acls_default    = var.environment == "production" ? "Deny" : "Allow"
  
  common_tags = local.common_tags
}

# ═══════════════════════════════════════════════════════════════
# MODULE 4: SQL Database with Auto-scaling
# ═══════════════════════════════════════════════════════════════
module "sql_database" {
  source = "./modules/sql-database"
  
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  unique_suffix       = random_string.unique.result
  
  # Environment-aware sizing
  database_sku      = local.current_env_config.sku_tier == "Basic" ? "Basic" : "S3"
  database_max_size = var.environment == "production" ? 250 : 50
  zone_redundant    = var.environment == "production"
  
  # Store credentials in Key Vault
  key_vault_id = module.key_vault.id
  
  common_tags = local.common_tags
  
  depends_on = [module.key_vault]
}

# ═══════════════════════════════════════════════════════════════
# MODULE 5: App Service with auto-scaling
# ═══════════════════════════════════════════════════════════════
module "app_service" {
  source = "./modules/app-service"
  
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  unique_suffix       = random_string.unique.result
  
  # Environment-aware configuration
  sku_name         = local.current_env_config.sku_tier == "Basic" ? "B1" : "P1v2"
  enable_always_on = local.current_env_config.sku_tier != "Basic"
  
  # Key Vault integration
  key_vault_id                   = module.key_vault.id
  key_vault_uri                  = module.key_vault.vault_uri
  sql_connection_string_secret_id = module.sql_database.connection_string_secret_id
  
  # Networking
  subnet_id = module.networking.subnet_ids["frontend"]
  
  common_tags = local.common_tags
  
  depends_on = [module.sql_database]
}

# ═══════════════════════════════════════════════════════════════
# MODULE 6: Monitoring
# ═══════════════════════════════════════════════════════════════
module "monitoring" {
  source = "./modules/monitoring"
  
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  
  # Environment-aware configuration
  app_insights_retention  = var.environment == "production" ? 90 : 30
  deploy_log_analytics    = local.current_env_config.enable_monitoring
  
  # Connect to App Service
  app_service_id = module.app_service.app_id
  
  common_tags = local.common_tags
}

# ═══════════════════════════════════════════════════════════════
# MODULE 7: Storage Account
# ═══════════════════════════════════════════════════════════════
module "storage_account" {
  source = "./modules/storage-account"
  
  project_name        = var.project_name
  environment         = var.environment
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  unique_suffix       = random_string.unique.result
  
  # Environment-aware replication
  replication_type = var.environment == "production" ? "GRS" : "LRS"
  
  # Store key in Key Vault
  key_vault_id = module.key_vault.id
  
  # Enable backup
  enable_backup = local.current_env_config.backup_enabled
  
  common_tags = local.common_tags
  
  depends_on = [module.key_vault]
}
