resource azurerm_resource_group bastion {
  name = "rg-${var.default_name}-bastion"
  tags = var.default_tags
  location = var.metadata_location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_public_ip bastion {
  name = "${var.default_name}-bastion"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.bastion.name
  location = var.resource_location
  allocation_method = "Static"
  sku = "Standard"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_network_security_group bastion {
  name = "${var.default_name}-bastion"
  resource_group_name = azurerm_resource_group.bastion.name
  location = var.resource_location

  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource azurerm_network_interface bastion {
  name = "${var.default_name}-bastion"
  resource_group_name = azurerm_resource_group.bastion.name
  location = var.resource_location

  ip_configuration {
    name = "ipconfig0"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_network_interface_security_group_association bastion {
  network_interface_id = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

data template_cloudinit_config bastion {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = replace(<<-EOF
      #cloud-config
      packages:
      - apt-utils
      EOF
      , "\r\n", "\n")
  }
}

resource azurerm_linux_virtual_machine bastion {
  name = "${var.default_name}-bastion"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.bastion.name
  location = var.resource_location
  
  size = "Standard_B2s"
  network_interface_ids = [azurerm_network_interface.bastion.id]
  disable_password_authentication = false
  secure_boot_enabled = true
  custom_data = data.template_cloudinit_config.bastion.rendered
  
  computer_name  = "${var.default_name}-bastion"
  admin_username = "sysadmin"
  admin_password = base64decode("SjY4TnhTOUcyUXhHczBHNyE=")

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name = "${var.default_name}-bastion-osdisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer = "ubuntu-24_04-lts"
    sku = "server"
    version = "latest"
  }

  boot_diagnostics {
    
  }

  lifecycle {
    ignore_changes = [tags, identity]
  }
}

resource azurerm_virtual_machine_extension bastion_aad_login {
  name = "AADSSHLogin"
  tags = var.default_tags

  virtual_machine_id = azurerm_linux_virtual_machine.bastion.id
  publisher = "Microsoft.Azure.ActiveDirectory"
  type = "AADSSHLoginForLinux"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true

  lifecycle {
    ignore_changes = [tags]
  }
}

resource azurerm_role_assignment bastion_aad_admin {
  role_definition_name = "Virtual Machine Administrator Login"
  scope = azurerm_linux_virtual_machine.bastion.id
  principal_id = data.azurerm_client_config.current.object_id
}
