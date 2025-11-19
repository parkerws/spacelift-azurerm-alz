terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Azure Landing Zone Management Group Hierarchy
# This example creates a complete ALZ management group structure

# Root management group for the organization
module "mg_root" {
  source = "../.."

  name         = "mg-contoso"
  display_name = "Contoso"
}

# Platform management group
module "mg_platform" {
  source = "../.."

  name                       = "mg-platform"
  display_name               = "Platform"
  parent_management_group_id = module.mg_root.id
}

# Connectivity management group (for hub networking)
module "mg_connectivity" {
  source = "../.."

  name                       = "mg-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = module.mg_platform.id

  # Example subscription IDs (replace with actual subscription IDs)
  subscription_ids = [
    # "00000000-0000-0000-0000-000000000001",
  ]
}

# Identity management group
module "mg_identity" {
  source = "../.."

  name                       = "mg-identity"
  display_name               = "Identity"
  parent_management_group_id = module.mg_platform.id

  subscription_ids = [
    # "00000000-0000-0000-0000-000000000002",
  ]
}

# Management management group (for monitoring and governance)
module "mg_management" {
  source = "../.."

  name                       = "mg-management"
  display_name               = "Management"
  parent_management_group_id = module.mg_platform.id

  subscription_ids = [
    # "00000000-0000-0000-0000-000000000003",
  ]
}

# Landing Zones management group
module "mg_landing_zones" {
  source = "../.."

  name                       = "mg-landing-zones"
  display_name               = "Landing Zones"
  parent_management_group_id = module.mg_root.id
}

# Corp landing zones (internal applications with on-premises connectivity)
module "mg_corp" {
  source = "../.."

  name                       = "mg-corp"
  display_name               = "Corp"
  parent_management_group_id = module.mg_landing_zones.id
}

# Online landing zones (internet-facing applications)
module "mg_online" {
  source = "../.."

  name                       = "mg-online"
  display_name               = "Online"
  parent_management_group_id = module.mg_landing_zones.id
}

# Sandbox management group for experimentation
module "mg_sandboxes" {
  source = "../.."

  name                       = "mg-sandboxes"
  display_name               = "Sandboxes"
  parent_management_group_id = module.mg_root.id
}

# Decommissioned management group for resources being retired
module "mg_decommissioned" {
  source = "../.."

  name                       = "mg-decommissioned"
  display_name               = "Decommissioned"
  parent_management_group_id = module.mg_root.id
}
