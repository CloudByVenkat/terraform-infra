# Day 22: Staging Environment Configuration

project_name = "cicdemo"
environment  = "staging"
location     = "Canada Central"

# Networking
vnet_address_space = ["10.1.0.0/16"]

# Metadata
owner_email = "svundela@cloudbyvenkat.com"
cost_center = "IT-Operations"
git_repo    = "https://github.com/cloudbyvenkat/terraform-infra"

# Feature flags (staging environment)
enable_advanced_threat_protection = true
enable_ddos_protection            = false
enable_private_endpoints          = true
