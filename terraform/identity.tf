resource azurerm_user_assigned_identity hub {
  name = var.default_name
  tags = var.default_tags
  resource_group_name = azurerm_resource_group.hub.name
  location = var.resource_location

  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource azurerm_role_assignment contributor {
  role_definition_name = "Contributor"
  scope = "/subscriptions/${var.subscription_id}"
  principal_id = azurerm_user_assigned_identity.hub.principal_id
}
