variable subscription_id {
  type = string
}

variable default_name {
  type = string
}

variable release_name {
  type = string
}

variable default_tags {
  type = map(string)
  default = {}
}

variable metadata_location {
  type = string
  description = "Location of the resource groups and other metadata items."
}

variable resource_location {
  type = string
  description = "Location of other resource items."
}

variable dns_zone_name {
  type = string
}

variable internal_dns_zone_name {
  type = string
}

variable vnet_address_prefixes {
  type = list(string)
}

variable default_vnet_subnet_address_prefixes {
  type = list(string)
}

variable private_vnet_subnet_address_prefixes {
  type = list(string)
}

variable dns_inbound_vnet_subnet_address_prefixes {
  type = list(string)
}

variable dns_outbound_vnet_subnet_address_prefixes {
  type = list(string)
}

variable bastion_vnet_subnet_address_prefixes {
  type = list(string)
}

variable vnet_peers {
  type = map(string)
}
