# Day 22: Outputs for CI/CD Pipeline Visibility

# ═══════════════════════════════════════════════════════════════
# Resource Identifiers
# ═══════════════════════════════════════════════════════════════

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.id
}

# ═══════════════════════════════════════════════════════════════
# Application URLs
# ═══════════════════════════════════════════════════════════════

output "app_service_url" {
  description = "Primary application URL"
  value       = module.app_service.app_url
}

output "app_service_default_hostname" {
  description = "App Service default hostname"
  value       = module.app_service.default_hostname
}

# ═══════════════════════════════════════════════════════════════
# Database Connection Info
# ═══════════════════════════════════════════════════════════════

output "sql_server_fqdn" {
  description = "SQL Server fully qualified domain name"
  value       = module.sql_database.server_fqdn
}

output "sql_database_name" {
  description = "SQL Database name"
  value       = module.sql_database.database_name
}

# ═══════════════════════════════════════════════════════════════
# Key Vault Info
# ═══════════════════════════════════════════════════════════════

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.vault_uri
}

# ═══════════════════════════════════════════════════════════════
# Monitoring Info
# ═══════════════════════════════════════════════════════════════

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.monitoring.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.connection_string
  sensitive   = true
}

# ═══════════════════════════════════════════════════════════════
# Deployment Summary (for Pipeline Display)
# ═══════════════════════════════════════════════════════════════

output "deployment_summary" {
  description = "Summary of deployed resources for CI/CD dashboard"
  value = {
    environment          = var.environment
    project             = var.project_name
    location            = var.location
    deployment_id       = var.deployment_id
    build_number        = var.build_number
    git_commit          = var.git_commit
    deployed_at         = timestamp()
    resource_group      = module.resource_group.name
    app_url             = module.app_service.app_url
    key_vault           = module.key_vault.name
    sql_server          = module.sql_database.server_name
    monitoring_enabled  = module.monitoring.log_analytics_deployed
  }
}

# ═══════════════════════════════════════════════════════════════
# Resource Counts (for Cost Tracking)
# ═══════════════════════════════════════════════════════════════

output "resource_counts" {
  description = "Count of deployed resources by type"
  value = {
    resource_groups  = 1
    vnets           = 1
    subnets         = length(module.networking.subnet_ids)
    app_services    = 1
    sql_servers     = 1
    key_vaults      = 1
    storage_accounts = 1
  }
}

# ═══════════════════════════════════════════════════════════════
# Post-Deployment Verification Commands
# ═══════════════════════════════════════════════════════════════

output "verification_commands" {
  description = "Commands to verify the deployment"
  value = <<-EOT
    # Verify App Service is running
    curl -I ${module.app_service.app_url}
    
    # Check App Service configuration
    az webapp config appsettings list \
      --name ${module.app_service.app_name} \
      --resource-group ${module.resource_group.name}
    
    # Verify Key Vault access
    az keyvault secret list \
      --vault-name ${module.key_vault.name} \
      --query "[].name" -o table
    
    # Check SQL Database status
    az sql db show \
      --name ${module.sql_database.database_name} \
      --server ${module.sql_database.server_name} \
      --resource-group ${module.resource_group.name} \
      --query "{Name:name, Status:status, SKU:sku.name}"
  EOT
}

# ═══════════════════════════════════════════════════════════════
# Rollback Information
# ═══════════════════════════════════════════════════════════════

output "rollback_info" {
  description = "Information needed for rollback"
  value = {
    state_file          = "${var.environment}.terraform.tfstate"
    deployment_id       = var.deployment_id
    resource_group_name = module.resource_group.name
    backup_command      = "terraform state pull > backup-${var.deployment_id}.tfstate"
  }
}
