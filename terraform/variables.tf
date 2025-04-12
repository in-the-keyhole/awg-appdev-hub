variable subscription_id {
  type = string
}

variable default_name {
  type = string
  default = "awg-hub"
}

variable release_name {
  type = string
  default = "1.0.0"
}

variable default_tags {
  type = map(string)
  default = {}
}

variable metadata_location {
  type = string
  default = "northcentralus"
  description = "Location of the resource groups and other metadata items."
}

variable resource_location {
  type = string
  default = "southcentralus"
  description = "Location of other resource items."
}

variable dns_zone_name {
  type = string
  default = "az.awginc.com"
}

variable int_dns_zone_name {
  type = string
  default = "az.int.awginc.com"
}

variable vnet_address_prefixes {
  type = list(string)
  default = ["10.223.0.0/16"]
}

variable default_vnet_subnet_address_prefixes {
  type = list(string)
  default = ["10.223.0.0/24"]
}

variable private_vnet_subnet_address_prefixes {
  type = list(string)
  default = ["10.223.1.0/24"]
}

variable dns_inbound_vnet_subnet_address_prefixes {
  type = list(string)
  default = ["10.223.254.0/28"]
}

variable dns_outbound_vnet_subnet_address_prefixes {
  type = list(string)
  default = ["10.223.254.16/28"]
}

variable bastion_vnet_subnet_address_prefixes {
  type = list(string)
  default = ["10.223.255.0/26"]
}
