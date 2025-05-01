resource azurerm_lb hub {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location

  frontend_ip_configuration {
    name = "openbao"
    subnet_id = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    zones = [1, 2, 3]
  }
  
  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  hub_lb_frontend_by_name = {for i in azurerm_lb.hub.frontend_ip_configuration : i.name => i}
}