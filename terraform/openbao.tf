resource azurerm_resource_group openbao {
  name = "rg-${var.default_name}-openbao"
  tags = var.default_tags
  location = var.metadata_location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_key_vault openbao {
  name = "${var.default_name}-openbao"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.openbao.name
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
    default_action = "Allow"
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
  key_vault_subresources = {
    vault = "privatelink.vaultcore.azure.net"
  }
}

resource azurerm_private_endpoint openbao_key_vault {
  for_each = local.key-vault-subresources

  name = "${azurerm_key_vault.openbao.name}-${each.key}-2-${azurerm_virtual_network.hub.name}"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.openbao.name
  location = azurerm_virtual_network.hub.location
  subnet_id = azurerm_subnet.private.id

  private_service_connection {
    name = "${azurerm_key_vault.openbao.name}-${each.key}-2-${azurerm_virtual_network.hub.name}"
    private_connection_resource_id = azurerm_key_vault.openbao.id
    subresource_names = [each.key]
    is_manual_connection = false
  }

  lifecycle {
    ignore_changes = [tags, private_dns_zone_group]
  }
}

resource azurerm_user_assigned_identity openbao {
  name = "${var.default_name}-openbao"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.openbao.name
  location = var.resource_location

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource azurerm_role_assignment openbao_key_vault_admin {
  role_definition_name = "Key Vault Administrator"
  scope = azurerm_key_vault.openbao.id
  principal_id = data.azurerm_client_config.current.object_id
}

resource azurerm_role_assignment openbao_key_vault_cert_user {
  role_definition_name = "Key Vault Certificate User"
  scope = azurerm_key_vault.openbao.id
  principal_id = azurerm_user_assigned_identity.openbao.principal_id
}

resource azurerm_role_assignment openbao_key_vault_secrets_user {
  role_definition_name = "Key Vault Secrets User"
  scope = azurerm_key_vault.openbao.id
  principal_id = azurerm_user_assigned_identity.openbao.principal_id
}

resource azurerm_role_assignment openbao_key_vault_crypto_user {
  role_definition_name = "Key Vault Crypto User"
  scope = azurerm_key_vault.openbao.id
  principal_id = azurerm_user_assigned_identity.openbao.principal_id
}

data azurerm_key_vault_certificate openbao_tls {
  name = "openbao-tls"
  key_vault_id = azurerm_key_vault.openbao.id
}

data azurerm_key_vault_secret openbao_tls {
  name = "openbao-tls"
  key_vault_id = azurerm_key_vault.openbao.id
}

resource azurerm_key_vault_key openbao {
  name = "openbao"
  key_vault_id = azurerm_key_vault.openbao.id
  key_type = "RSA"
  key_size = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

module openbao {
  source = "../../awg-appdev-modules/terraform/openbao"
  name = "${var.default_name}-openbao"
  tags = var.default_tags
  resource_group = azurerm_resource_group.openbao
  location = var.resource_location
  identity = azurerm_user_assigned_identity.openbao
  zones = [1,2,3]
  vm_sku = "Standard_B2ts_v2"
  vnet = azurerm_virtual_network.hub
  subnet = azurerm_subnet.default
  load_balancer = azurerm_lb.hub
  load_balancer_front_end = local.hub_lb_frontend_by_name["openbao"]
  dns_name = "ca.${var.internal_dns_zone_name}"
  instance_count = 5
  admin_username = "sysadmin"
  admin_password = base64decode("SjY4TnhTOUcyUXhHczBHNyE=")
  root_ca_certs = var.root_ca_certs
  keyvault = azurerm_key_vault.openbao
  keyvault_key = azurerm_key_vault_key.openbao
  tls_keyvault_certificate = data.azurerm_key_vault_certificate.openbao_tls

  depends_on = [ 
    azurerm_role_assignment.openbao_key_vault_cert_user,
    azurerm_role_assignment.openbao_key_vault_secrets_user,
    azurerm_role_assignment.openbao_key_vault_crypto_user,
    azurerm_subnet_nat_gateway_association.default
  ]
}

resource azurerm_private_dns_a_record openbao {
  name = "ca"
  tags = var.default_tags
  resource_group_name = azurerm_private_dns_zone.internal.resource_group_name
  zone_name = azurerm_private_dns_zone.internal.name
  records = [local.hub_lb_frontend_by_name["openbao"].private_ip_address]
  ttl = 300

  lifecycle {
    ignore_changes = [ tags ]
  }
}
