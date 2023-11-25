variable "location" {
  description = "Resource Creation location"
  type        = string
  default     = "East Us"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use for the resources that are deployed"

  default = {
    environment = "codelab"
  }
}

variable "resource_group_name" {
  description = "The name of resource group in which the resources are created"
  type        = string
  default     = "VMSS"
}

locals {
  regions_with_availability_zones = ["eastus"] #["centralus","eastus2","eastus","westus"]
  zones                           = contains(local.regions_with_availability_zones, var.location) ? list("1", "2", "3") : null
}

variable "azurerm_virtual_network" {
  description = "The name of the virtual network in which the resources will be created"
  type        = string
  default     = "VMSSnet"
}

variable "azurerm_virtual_machine_scale_set" {
  description = "Name of Virtual machine scale set"
  type        = string
  default     = "VMScaleSet"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["eastus"]
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
}
