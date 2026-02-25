# Day 22: Variables for CI/CD Pipeline

variable "project_name" {
  description = "Name of the project - used in resource naming"
  type        = string
  
  validation {
    condition     = length(var.project_name) <= 12 && can(regex("^[a-z0-9]+$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric, max 12 characters."
  }
}

variable "environment" {
  description = "Environment name - drives all configuration"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# ═══════════════════════════════════════════════════════════════
# Tags and Metadata (Required for Enterprise Governance)
# ═══════════════════════════════════════════════════════════════

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "IT-Infrastructure"
}

variable "owner_email" {
  description = "Email of the infrastructure owner"
  type        = string
}

variable "git_repo" {
  description = "Git repository URL"
  type        = string
  default     = "https://github.com/yourorg/terraform-infra"
}

# ═══════════════════════════════════════════════════════════════
# Feature Flags (Control features per environment)
# ═══════════════════════════════════════════════════════════════

variable "enable_advanced_threat_protection" {
  description = "Enable Azure Defender for SQL"
  type        = bool
  default     = false
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection on VNet"
  type        = bool
  default     = false
}

variable "enable_private_endpoints" {
  description = "Use private endpoints for PaaS services"
  type        = bool
  default     = false
}

# ═══════════════════════════════════════════════════════════════
# CI/CD Specific Variables
# ═══════════════════════════════════════════════════════════════

variable "deployment_id" {
  description = "Unique deployment identifier from CI/CD"
  type        = string
  default     = "manual"
}

variable "build_number" {
  description = "Build number from CI/CD pipeline"
  type        = string
  default     = "0"
}

variable "git_commit" {
  description = "Git commit SHA"
  type        = string
  default     = "unknown"
}
