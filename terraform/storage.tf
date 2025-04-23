resource azurerm_storage_account hub {
  name = replace(var.default_name, "-", "")
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  account_tier = "Standard"
  account_kind = "StorageV2"
  account_replication_type = "LRS"
  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [tags]
    prevent_destroy = true
  }
}

locals {
  storage_subresources = {
    "blob" = "privatelink.blob.core.windows.net",
    "file" = "privatelink.file.core.windows.net",
    "table" = "privatelink.table.core.windows.net",
    "queue" = "privatelink.queue.core.windows.net",
    "web" = "privatelink.web.core.windows.net"
  }
}

resource azurerm_private_endpoint storage_account {
  for_each = local.storage_subresources

  name = "${azurerm_storage_account.hub.name}-${each.key}-2-${azurerm_virtual_network.hub.name}"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = azurerm_virtual_network.hub.location
  subnet_id = azurerm_subnet.default.id

  private_service_connection {
    name = "${azurerm_storage_account.hub.name}-${each.key}-2-${azurerm_virtual_network.hub.name}"
    private_connection_resource_id = azurerm_storage_account.hub.id
    subresource_names = [each.key]
    is_manual_connection = false
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group]
  }
}
