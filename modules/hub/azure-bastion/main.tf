locals {
  # Use provided or created public IP
  public_ip_id = var.create_public_ip ? azurerm_public_ip.bastion[0].id : var.public_ip_address_id
}

# Create public IP if not provided
resource "azurerm_public_ip" "bastion" {
  count = var.create_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.public_ip_sku
  allocation_method   = var.public_ip_allocation_method
  zones               = var.zones

  tags = merge(
    var.tags,
    {
      Purpose = "AzureBastion"
    }
  )
}

# Azure Bastion Host
resource "azurerm_bastion_host" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  scale_units         = var.sku != "Basic" ? var.scale_units : null

  copy_paste_enabled       = var.copy_paste_enabled
  file_copy_enabled        = var.sku != "Basic" ? var.file_copy_enabled : null
  ip_connect_enabled       = var.sku != "Basic" ? var.ip_connect_enabled : null
  shareable_link_enabled   = var.sku != "Basic" ? var.shareable_link_enabled : null
  tunneling_enabled        = var.sku != "Basic" ? var.tunneling_enabled : null
  kerberos_enabled         = var.sku != "Basic" ? var.kerberos_enabled : null
  zones                    = var.sku != "Basic" ? var.zones : null

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = local.public_ip_id
  }

  tags = var.tags

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false
  }

  depends_on = [
    azurerm_public_ip.bastion
  ]
}
