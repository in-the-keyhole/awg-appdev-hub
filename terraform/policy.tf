###
# Import all policy definitions in the policyDefinitions directory.
###

locals {
  policy_json_files = fileset(path.module, "policyDefinitions/*.json")
  policy_json_data = [for f in local.policy_json_files : jsondecode(file("${path.module}/${f}"))]
  policy_json_defs = {for f in local.policy_json_data : f.name => f }
}

resource azurerm_policy_definition policies {
  for_each = local.policy_json_defs

  name = each.key
  policy_type = each.value.properties.policyType
  mode = each.value.properties.mode
  display_name = each.value.properties.displayName
  description = each.value.properties.description
  metadata = jsonencode(each.value.properties.metadata)
  parameters = jsonencode(each.value.properties.parameters)
  policy_rule = jsonencode(each.value.properties.policyRule)
}

locals {
  policy_by_name = {for i in azurerm_policy_definition.policies : i.name => i}
}

###
# Import all policy set definitions in the policySetDefinitions directory.
###

locals {
  policyset_json_files = fileset(path.module, "policySetDefinitions/*.json")
  policyset_json_data = [for f in local.policyset_json_files : jsondecode(file("${path.module}/${f}"))]
  policyset_json_defs = {for f in local.policyset_json_data : f.name => f}
}

resource azurerm_policy_set_definition policy_sets {
  for_each = local.policyset_json_defs

  name = each.key
  policy_type  = each.value.properties.policyType
  display_name = each.value.properties.displayName
  description = each.value.properties.description
  metadata = jsonencode(each.value.properties.metadata)
  parameters = jsonencode(each.value.properties.parameters)

  dynamic policy_definition_reference {
    for_each = [ for j in each.value.properties.policyDefinitions : j ]

    content {
      reference_id = policy_definition_reference.value.policyDefinitionReferenceId
      policy_definition_id = lookup(local.policy_by_name, policy_definition_reference.value.policyDefinitionReferenceId, "") == "" ? policy_definition_reference.value.policyDefinitionId  : local.policy_by_name[policy_definition_reference.value.policyDefinitionReferenceId].id
      parameter_values = jsonencode(policy_definition_reference.value.parameters)
    }
  }
}

###
# Assignments
###

resource azurerm_subscription_policy_assignment deploy_private_dns_zones {
  name = "deploy_private_dns_zones"
  location = var.metadata_location

  policy_definition_id = azurerm_policy_set_definition.policy_sets["DINE-Deploy-Private-DNS-Zones"].id
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
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.hub.id ]
  }
}

resource azurerm_role_assignment deploy_private_dns_zones_contributor {
  role_definition_name = "Contributor"
  scope = "/subscriptions/${var.subscription_id}"
  principal_id = azurerm_user_assigned_identity.hub.principal_id
}

resource azurerm_role_assignment deploy_private_dns_zones_private_dns_contributor {
  role_definition_name = "Private DNS Zone Contributor"
  scope = "/subscriptions/${var.subscription_id}"
  principal_id = azurerm_user_assigned_identity.hub.principal_id
}

resource azurerm_role_assignment deploy_private_dns_zones_network_contributor {
  role_definition_name = "Network Contributor"
  scope = "/subscriptions/${var.subscription_id}"
  principal_id = azurerm_user_assigned_identity.hub.principal_id
}

locals {
  policy_deps = [
    azurerm_subscription_policy_assignment.deploy_private_dns_zones,
    azurerm_role_assignment.deploy_private_dns_zones_contributor,
    azurerm_role_assignment.deploy_private_dns_zones_private_dns_contributor,
    azurerm_role_assignment.deploy_private_dns_zones_network_contributor
  ]
}
