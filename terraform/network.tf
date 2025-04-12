# public DNS zone
resource azurerm_dns_zone public {
  name = var.dns_zone_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  
  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_virtual_network hub {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  address_space = var.vnet_address_prefixes

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

resource azurerm_subnet dns-inbound {
  name = "dns-inbound"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.dns_inbound_vnet_subnet_address_prefixes
  
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action", 
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource azurerm_subnet dns-outbound {
  name = "dns-outbound"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.dns_outbound_vnet_subnet_address_prefixes
  
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action", 
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource azurerm_subnet bastion {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes = var.bastion_vnet_subnet_address_prefixes
}

resource azurerm_private_dns_zone internal {
  name = var.internal_dns_zone_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  
  lifecycle {
    ignore_changes = [tags]
  }
}

# link the internal DNS zone to the VNet
resource azurerm_private_dns_zone_virtual_network_link internal {
  name = "${azurerm_private_dns_zone.internal.name}-2-${azurerm_virtual_network.hub.name}"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id = azurerm_virtual_network.hub.id
  
  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [ 
    azurerm_private_dns_zone.internal
  ]
}

# allows private resolution of DNS within the VNet
resource azurerm_private_dns_resolver hub {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  virtual_network_id  = azurerm_virtual_network.hub.id

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_private_dns_resolver_inbound_endpoint default {
  name = var.default_name
  tags = var.default_tags
  location = azurerm_private_dns_resolver.hub.location
  private_dns_resolver_id = azurerm_private_dns_resolver.hub.id

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id = azurerm_subnet.dns-inbound.id
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    azurerm_subnet.dns-inbound
  ]
}

# resource azurerm_private_dns_resolver_outbound_endpoint default {
#   name = var.default_name
#   tags = var.default_tags
#   location = azurerm_private_dns_resolver.hub.location
#   private_dns_resolver_id = azurerm_private_dns_resolver.hub.id
#   subnet_id = azurerm_subnet.dns-outbound.id

#   lifecycle {
#     ignore_changes = [tags]
#   }

#   depends_on = [
#     azurerm_subnet.dns-outbound
#   ]
# }

# resource azurerm_private_dns_resolver_dns_forwarding_ruleset default {
#   name = var.default_name
#   tags = var.default_tags
#   location = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.default.id]
  
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource azurerm_private_dns_resolver_forwarding_rule local {
#   name = "local"
#   dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.default.id
#   domain_name = "local."
#   enabled = true

#   target_dns_servers {
#     ip_address = "10.0.0.4"
#     port = 53
#   }

#   target_dns_servers {
#     ip_address = "10.0.0.5"
#     port = 53
#   }
# }

locals {
  privatelink_zone_names = toset([
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.web.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.database.windows.net",
    "privatelink.azuredatabricks.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.datafactory.azure.net",
    "privatelink.ncus.backup.windowsazure.com",
    "privatelink.openai.azure.com",
    "privatelink.azurecr.io",
    "privatelink.southcentralus.azmk8s.io"
  ])
}

# generate a private DNS zone for each item in the name table
resource azurerm_private_dns_zone privatelink_zones {
  for_each =  local.privatelink_zone_names

  name = each.key
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name

  lifecycle {
    ignore_changes = [tags]
  }
}

# calculate map of private zone name to resource
locals {
  privatelink_zones_by_name = {
    for i in azurerm_private_dns_zone.privatelink_zones : i.name => i
  }
}

# link each private DNS zone with the hub network
resource azurerm_private_dns_zone_virtual_network_link privatelink {
  for_each =  local.privatelink_zone_names

  name = "${local.privatelink_zones_by_name[each.key].name}-2-${azurerm_virtual_network.hub.name}"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  private_dns_zone_name = local.privatelink_zones_by_name[each.key].name
  virtual_network_id = azurerm_virtual_network.hub.id

  lifecycle {
    ignore_changes = [tags]
  }
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
