resource "azurerm_resource_group" "tfprodgs" {
  name     = "tfprodrg"
  location = "West US 2"
}

resource "azurerm_virtual_network" "tfprodgs" {
  name                = "tfvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.tfprodgs.name}"
}

resource "azurerm_subnet" "tfprodgs" {
  name                 = "tfsubnet"
  resource_group_name  = "${azurerm_resource_group.tfprodgs.name}"
  virtual_network_name = "${azurerm_virtual_network.tfprodgs.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "tfprodgs" {
  name                = "tfnet"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.tfprodgs.name}"

  ip_configuration {
    name                          = "tfipconfigprod"
    subnet_id                     = "${azurerm_subnet.tfprodgs.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "tfprodgs" {
  name                 = "tdprod_data"
  location             = "West US 2"
  resource_group_name  = "${azurerm_resource_group.tfprodgs.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "tfprodgs" {
  name                  = "tfprodgsvm"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.tfprodgs.name}"
  network_interface_ids = ["${azurerm_network_interface.tfprodgs.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "tfosdiskprod"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "tfproddata"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  os_profile {
    computer_name  = "tfprodgs"
    admin_username = "changeme"
    admin_password = "changeme"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "demo"
  }
}