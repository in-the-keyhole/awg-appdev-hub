resource "azurerm_storage_account" "hub" {
  name = replace(var.default_name, "-", "")
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  account_tier = "Standard"
  account_kind = "StorageV2"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_private_endpoint" "azurerm_storage_account" {
  name = azurerm_storage_account.hub.name
  resource_group_name = azurerm_resource_group.hub.name
  location = azurerm_virtual_network.hub.location
  subnet_id = azurerm_subnet.default.id

  private_service_connection {
    name = azurerm_storage_account.hub.name
    private_connection_resource_id = azurerm_storage_account.hub.id
    subresource_names = ["blob"]
    is_manual_connection = false
  }

  private_dns_zone_group {
    name = azurerm_storage_account.hub.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink-blob-core.id]
  }
}
