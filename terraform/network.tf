resource "azurerm_dns_zone" "pub" {
  name = var.dns_zone_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_virtual_network" "hub" {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  address_space = var.vnet_address_prefixes
}

resource "azurerm_subnet" "default" {
  name = "default"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.default_vnet_subnet_address_prefixes
}

resource "azurerm_subnet" "private" {
  name = "private"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.private_vnet_subnet_address_prefixes
  private_link_service_network_policies_enabled = true
}

resource "azurerm_subnet" "bastion" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.bastion_vnet_subnet_address_prefixes
}

resource "azurerm_private_dns_zone" "int" {
  name = var.int_dns_zone_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "az" {
  name = azurerm_private_dns_zone.int.name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.int.name
  virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_resolver" "hub" {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  virtual_network_id  = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone" "privatelink-database" {
  name = "privatelink.database.windows.net"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink-database" {
  name = "privatelink-database"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink-database.name
  virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone" "privatelink-blob-core" {
  name = "privatelink.blob.core.windows.net"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink-blob-core" {
  name = "privatelink-blob-core"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink-blob-core.name
  virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone" "privatelink-vaultcore" {
  name = "privatelink.vaultcore.azure.net"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink-vaultcore" {
  name = "privatelink-vaultcore"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink-vaultcore.name
  virtual_network_id = azurerm_virtual_network.hub.id
}
