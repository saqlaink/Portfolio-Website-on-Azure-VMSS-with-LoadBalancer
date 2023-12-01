resource "azurerm_resource_group" "vmss" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_virtual_network" "vmss" {
  name                = var.azurerm_virtual_network
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  tags                = var.tags
}

resource "azurerm_subnet" "vmss" {
  name                 = "vmss-subnet"
  resource_group_name  = azurerm_resource_group.vmss.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmss" {
  name                = "vmss-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

resource "azurerm_lb" "vmss" {
  name                = "vmss-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepoll" {
  name            = "BackEndAddressPool"
  loadbalancer_id = azurerm_lb.vmss.id
  # resource_group_name = azurerm_resource_group.vmss.name
}

resource "azurerm_lb_probe" "vmss" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "ssh-running-probe"
  port            = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id                = azurerm_lb.vmss.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss.id
}

# resource "azurerm_virtual_machine_scale_set" "vmss" {
#   name                = var.azurerm_virtual_machine_scale_set
#   location            = var.location
#   resource_group_name = azurerm_resource_group.vmss.name
#   upgrade_policy_mode = "Manual"

#   zones = local.zones

#   sku {
#     name     = "Standard_B1S"
#     tier     = "Standard"
#     capacity = 2
#   }

#   storage_profile_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   storage_profile_os_disk {
#     name              = ""
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   storage_profile_data_disk {
#     lun           = 0
#     caching       = "ReadWrite"
#     create_option = "Empty"
#     disk_size_gb  = 10
#   }

#   os_profile {
#     computer_name_prefix = "vmlab"
#     admin_username       = var.admin_user
#     admin_password       = var.admin_password
#     custom_data          = file("web.conf")
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   network_profile {
#     name    = "terraformnetworkprofile"
#     primary = true

#     ip_configuration {
#       name                                   = "IPConfiguration"
#       primary                                = true
#       subnet_id                              = azurerm_subnet.vmss.id
#       load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepoll.id]
#     }
#   }
#   tags = var.tags
# }

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.azurerm_virtual_machine_scale_set
  resource_group_name = azurerm_resource_group.vmss.name
  location            = var.location
  sku                 = "Standard_B1S"
  instances           = 2
  admin_username      = var.admin_user
  admin_password      = var.admin_password
  tags                = var.tags

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepoll.id]
    }
  }
}


/*
resource "azurerm_virtual_machine_scale_set_extension" "example" {
  name                         = "example"
  virtual_machine_scale_set_id = azurerm_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
    "commandToExecute" = "echo Hello World $HOSTNAME"
  })
}
*/

resource "azurerm_monitor_autoscale_setting" "vmss" {
  name                = "AutoscaleSetting"
  resource_group_name = azurerm_resource_group.vmss.name
  location            = azurerm_resource_group.vmss.location
  target_resource_id  = azurerm_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["saqlainkhan25@gmail.com"]
    }
  }
}
