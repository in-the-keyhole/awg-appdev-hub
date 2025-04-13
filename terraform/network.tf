resource azurerm_virtual_network hub {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  address_space = var.vnet_address_prefixes
  dns_servers = var.vnet_dns_servers

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_subnet default {
  name = "default"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.default_vnet_subnet_address_prefixes
}

resource azurerm_subnet private {
  name = "private"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.private_vnet_subnet_address_prefixes
  private_link_service_network_policies_enabled = true
}

resource azurerm_subnet dns {
  name = "dns"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.dns_vnet_subnet_address_prefixes
}

resource azurerm_subnet bastion {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.bastion_vnet_subnet_address_prefixes
}

# peer the private spoke virtual network with the hub virtual network
resource azurerm_virtual_network_peering peers {
  for_each = var.vnet_peers

  name = "${var.default_name}-2-${each.key}"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  remote_virtual_network_id = each.value
  allow_virtual_network_access = true
  allow_forwarded_traffic = false
  allow_gateway_transit = false

  lifecycle {
    prevent_destroy = true
  }
}
