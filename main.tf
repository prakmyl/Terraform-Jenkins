terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "prk-rsrc" {
  name     = "prk-resource"
  location = "centralindia"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "prk-nw" {
  name                = "prk-network"
  location            = azurerm_resource_group.prk-rsrc.location
  resource_group_name = azurerm_resource_group.prk-rsrc.name
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "prk-sub" {
  name                 = "prk-subnet"
  resource_group_name  = azurerm_resource_group.prk-rsrc.name
  virtual_network_name = azurerm_virtual_network.prk-nw.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_security_group" "prk-sg" {
  name                = "prk-security-group"
  location            = azurerm_resource_group.prk-rsrc.location
  resource_group_name = azurerm_resource_group.prk-rsrc.name



}
resource "azurerm_network_security_rule" "prk-secrule" {
  name                        = "prk-security-rule"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.prk-rsrc.name
  network_security_group_name = azurerm_network_security_group.prk-sg.name
}

resource "azurerm_subnet_network_security_group_association" "prk-sgassoc" {
  subnet_id                 = azurerm_subnet.prk-sub.id
  network_security_group_id = azurerm_network_security_group.prk-sg.id
}

resource "azurerm_public_ip" "prk-pbip" {
  name                = "prk-public-ip"
  resource_group_name = azurerm_resource_group.prk-rsrc.name
  location            = azurerm_resource_group.prk-rsrc.location
  allocation_method   = "Dynamic"


  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "prk-nic" {
  name                = "prk-network-interface"
  location            = azurerm_resource_group.prk-rsrc.location
  resource_group_name = azurerm_resource_group.prk-rsrc.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prk-sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.prk-pbip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "prk-vm" {

  name                = "prk-ubuntu-vm"
  resource_group_name = azurerm_resource_group.prk-rsrc.name
  location            = azurerm_resource_group.prk-rsrc.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  #admin_password                  = "root@123"
  #disable_password_authentication = "false"
  network_interface_ids = [ azurerm_network_interface.prk-nic.id ]
 

 custom_data  = filebase64("${path.module}/customdata.tpl")

  


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
     offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"

  }
}
 
