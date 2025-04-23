locals {
  deploy_private_dns_zones = jsondecode(file("./policySetDefinitions/Deploy-Private-DNS-Zones.json"))
}

resource azurerm_policy_set_definition deploy_private_dns_zones {
  name = local.deploy_private_dns_zones.name

  policy_type  = local.deploy_private_dns_zones.properties.policyType
  display_name = local.deploy_private_dns_zones.properties.displayName
  description = local.deploy_private_dns_zones.properties.description
  metadata = jsonencode(local.deploy_private_dns_zones.properties.metadata)
  parameters = jsonencode(local.deploy_private_dns_zones.properties.parameters)

  dynamic policy_definition_reference {
    for_each = [ for j in local.deploy_private_dns_zones.properties.policyDefinitions : j ]

    content {
      reference_id = policy_definition_reference.value.policyDefinitionReferenceId
      policy_definition_id = policy_definition_reference.value.policyDefinitionId
      parameter_values = jsonencode({
        for n, v in policy_definition_reference.value.parameters : n => v
      })
    }
  }

}

resource azurerm_subscription_policy_assignment deploy_private_dns_zones {
  name = "deploy_private_dns_zones"
  location = var.metadata_location

  policy_definition_id = azurerm_policy_set_definition.deploy_private_dns_zones.id
  subscription_id = "/subscriptions/${var.subscription_id}"
  
  parameters = jsonencode({
    dnsZoneSubscriptionId = {
        value = var.subscription_id
    }
    dnsZoneResourceGroupName = {
        value = azurerm_resource_group.hub.name
    }
    dnsZoneRegion = {
        value = var.resource_location
    }
  })

  identity {
    type = "SystemAssigned"
  }
}

# resource azurerm_subscription_policy_remediation deploy_private_dns_zones {
#   for_each = { for k, v in local.deploy_private_dns_zones.properties.policyDefinitions : v.policyDefinitionReferenceId => v }

#   name = "deploy_private_dns_zones__${replace(lower(each.key), "-", "_")}"
#   subscription_id = "/subscriptions/${var.subscription_id}"
#   policy_assignment_id = azurerm_subscription_policy_assignment.deploy_private_dns_zones.id
#   policy_definition_reference_id = lower(each.key)
# }

resource azurerm_role_assignment deploy_private_dns_zones_contributor {
  role_definition_name = "Contributor"
  scope = "/subscriptions/${var.subscription_id}"
  principal_id = azurerm_subscription_policy_assignment.deploy_private_dns_zones.identity[0].principal_id
}

resource azurerm_role_assignment deploy_private_dns_zones_private_dns_contributor {
  role_definition_name = "Private DNS Zone Contributor"
  scope = "/subscriptions/${var.subscription_id}"
  principal_id = azurerm_subscription_policy_assignment.deploy_private_dns_zones.identity[0].principal_id
}

resource azurerm_role_assignment deploy_private_dns_zones_network_contributor {
  role_definition_name = "Network Contributor"
  scope = "/subscriptions/${var.subscription_id}"
  principal_id = azurerm_subscription_policy_assignment.deploy_private_dns_zones.identity[0].principal_id
}
