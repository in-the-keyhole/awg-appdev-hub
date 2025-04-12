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

resource azurerm_linux_virtual_machine bastion {
  name = "${var.default_name}-bastion"
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.bastion.name
  location = var.resource_location
  network_interface_ids = [azurerm_network_interface.bastion.id]
  size = "Standard_B1s"
  disable_password_authentication = false

  os_disk {
    name = "${var.default_name}-bastion-osdisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
    version = "latest"
  }
  
  computer_name  = "${var.default_name}-bastion"
  admin_username = "sysadmin"
  admin_password = base64decode("SjY4TnhTOUcyUXhHczBHNyE=")

  lifecycle {
    ignore_changes = [tags]
  }
}
