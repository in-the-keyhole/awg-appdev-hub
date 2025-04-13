# public DNS zone
resource azurerm_dns_zone public {
  name = var.dns_zone_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  
  lifecycle {
    ignore_changes = [tags]
  }
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

# calculate map of private zone name to resource
locals {
  privatelink_zone_rules = {
    for i in azurerm_private_dns_zone.privatelink_zones : i.name => [ "168.63.129.16" ]
  }
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

# deploys a DNS resolver in the hub that forwards to MS DNS by default and for private zones and then otherwise follows the variable rules
module dns_resolver {
  source = "../../awg-appdev-modules/terraform/dns-resolver"
  name = var.default_name
  tags = var.default_tags
  resource_group = azurerm_resource_group.hub
  location = var.resource_location
  subnet = azurerm_subnet.dns
  addresses = var.dns_resolver_addresses
  rules = merge({ "." = [ "168.63.129.16" ]}, local.privatelink_zone_rules, var.dns_resolver_rules)
}

output dns_resolver_password {
  value = nonsensitive(module.dns_resolver.password)
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
