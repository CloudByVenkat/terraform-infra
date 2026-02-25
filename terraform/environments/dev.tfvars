# Day 22: Development Environment Configuration

project_name = "cicdemo"
environment  = "dev"
location     = "East US"

# Networking
vnet_address_space = ["10.0.0.0/16"]

# Metadata
owner_email = "devteam@company.com"
cost_center = "IT-Development"
git_repo    = "https://github.com/yourorg/terraform-infra"

# Feature flags (dev environment)
enable_advanced_threat_protection = false
enable_ddos_protection            = false
enable_private_endpoints          = false
