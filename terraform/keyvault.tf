resource azurerm_key_vault hub {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location
  sku_name = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = true
  enable_rbac_authorization = true
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
  access_policy = []

  network_acls {
    default_action = "Deny"
    bypass = "AzureServices"
    ip_rules = []
    virtual_network_subnet_ids = []
  }

  lifecycle {
    ignore_changes = [ tags ]
    prevent_destroy = true
  }
}

locals {
  key-vault-subresources = {
    "vault" = "privatelink.vaultcore.azure.net"
  }
}

# expose each service of the general use key vault to the private VNet
resource azurerm_private_endpoint key_vault {
  for_each = local.key-vault-subresources

  name = "${azurerm_key_vault.hub.name}-${each.key}-2-${azurerm_virtual_network.hub.name}"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = azurerm_virtual_network.hub.location
  subnet_id = azurerm_subnet.private.id

  private_service_connection {
    name = "${azurerm_key_vault.hub.name}-${each.key}-2-${azurerm_virtual_network.hub.name}"
    private_connection_resource_id = azurerm_key_vault.hub.id
    subresource_names = [each.key]
    is_manual_connection = false
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group]
  }
}

resource azurerm_role_assignment key_vault_admin {
  role_definition_name = "Key Vault Administrator"
  scope = azurerm_key_vault.hub.id
  principal_id = data.azurerm_client_config.current.object_id
}
