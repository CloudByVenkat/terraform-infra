# Day 22: Production Environment Configuration

project_name = "cicdemo"
environment  = "production"
location     = "Canada Central"

# Networking
vnet_address_space = ["10.2.0.0/16"]

# Metadata
owner_email = "svundela@cloudbyvenkat.com"
cost_center = "IT-Production"
git_repo    = "https://github.com/cloudbyvenkat/terraform-infra"

# Feature flags (production environment - all security features enabled)
enable_advanced_threat_protection = true
enable_ddos_protection            = true
enable_private_endpoints          = true
