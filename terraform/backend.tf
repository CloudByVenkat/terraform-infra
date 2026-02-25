# Day 22: Backend Configuration for CI/CD
# This file configures remote state storage in Azure Storage

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Backend configuration
  # Values passed via CLI in pipeline: -backend-config flags
  backend "azurerm" {
    # resource_group_name  = "rg-terraform-state"      # Passed via pipeline
    # storage_account_name = "sttfstatedev"            # Passed via pipeline
    # container_name       = "tfstate"                 # Passed via pipeline
    # key                  = "dev.terraform.tfstate"   # Passed via pipeline
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = var.environment == "production" ? true : false
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = var.environment != "production"
      recover_soft_deleted_key_vaults = true
    }
  }
  
  # Skip provider registration in CI/CD to speed up deployments
  skip_provider_registration = true
}

# Data source for current Azure client
data "azurerm_client_config" "current" {}

# Common tags applied to all resources
locals {
  common_tags = {
    Environment     = var.environment
    Project         = var.project_name
    ManagedBy       = "Terraform"
    DeployedBy      = "CI/CD Pipeline"
    CostCenter      = var.cost_center
    Owner           = var.owner_email
    GitRepo         = var.git_repo
    LastDeployment  = timestamp()
  }
  
  # Environment-specific configuration
  env_config = {
    dev = {
      sku_tier          = "Basic"
      enable_monitoring = false
      backup_enabled    = false
    }
    staging = {
      sku_tier          = "Standard"
      enable_monitoring = true
      backup_enabled    = true
    }
    production = {
      sku_tier          = "Premium"
      enable_monitoring = true
      backup_enabled    = true
    }
  }
  
  # Current environment config
  current_env_config = local.env_config[var.environment]
}
