variable "subscription_id" {
  type = string
}

variable "default_name" {
  type = string
  default = "awg-app"
}

variable "release_name" {
  type = string
  default = "1.0.0"
}

variable "default_tags" {
  type = map(string)
  default = {}
}

variable "metadata_location" {
  type = string
  default = "westus"
  description = "Location of the resource groups and other metadata items."
}

variable "resource_location" {
  type = string
  default = "eastus"
  description = "Location of other resource items."
}

variable "vnet_address_prefixes" {
  type = list(string)
  default = ["10.223.0.0/16"]
}

variable "default_vnet_subnet_address_prefixes" {
  type = list(string)
  default = ["10.223.0.0/24"]
}

variable "dns_zone_name" {
  type = string
  default = "az.awginc.com"
}

variable "int_dns_zone_name" {
  type = string
  default = "az.int.awginc.com"
}

variable "private_vnet_subnet_address_prefixes" {
  type = list(string)
  default = ["10.223.1.0/24"]
}

variable "bastion_vnet_subnet_address_prefixes" {
  type = list(string)
  default = ["10.223.2.0/24"]
}
