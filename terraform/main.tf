terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>2.3"
    }
  }
  backend azurerm {
    
  }
}

provider azurerm {
  features {}
  subscription_id = var.subscription_id
}

data azurerm_client_config current {

}

resource azurerm_resource_group hub {
  name = "rg-${var.default_name}"
  tags = var.default_tags
  location = var.metadata_location

  lifecycle {
    ignore_changes = [tags]
  }
}
