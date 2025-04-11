
resource "azurerm_resource_group" "bastion" {
  name = "rg-${var.default_name}-bastion"
  tags = var.default_tags
  location = var.metadata_location
}

resource "azurerm_public_ip" "bastion_ip" {
  name = "${var.default_name}-bastion-ip"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.bastion.name
  location = var.resource_location
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.bastion.name
  location = var.resource_location

  ip_configuration {
    name = "configuration"
    subnet_id = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}
