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

resource azurerm_nat_gateway hub {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  sku_name = "Standard"
  idle_timeout_in_minutes = 10

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_public_ip nat {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  allocation_method = "Static"
  sku = "Standard"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_nat_gateway_public_ip_association hub {
  nat_gateway_id = azurerm_nat_gateway.hub.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource azurerm_subnet_nat_gateway_association default {
  nat_gateway_id = azurerm_nat_gateway.hub.id
  subnet_id = azurerm_subnet.default.id
}

resource azurerm_subnet_nat_gateway_association dns {
  nat_gateway_id = azurerm_nat_gateway.hub.id
  subnet_id = azurerm_subnet.dns.id
}

resource azurerm_subnet_nat_gateway_association bastion {
  nat_gateway_id = azurerm_nat_gateway.hub.id
  subnet_id = azurerm_subnet.bastion.id
}
