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

variable dns_resolver_addresses {
  type = list(string)
}

variable dns_resolver_rules {
  type = map(list(string))
}

variable vnet_address_prefixes {
  type = list(string)
}

variable vnet_dns_servers {
  type = list(string)
}

variable vnet_peers {
  type = map(string)
}

variable default_vnet_subnet_address_prefixes {
  type = list(string)
}

variable private_vnet_subnet_address_prefixes {
  type = list(string)
}

variable dns_vnet_subnet_address_prefixes {
  type = list(string)
}

variable bastion_vnet_subnet_address_prefixes {
  type = list(string)
}
