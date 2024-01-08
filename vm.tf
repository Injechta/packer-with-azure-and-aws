provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "b3-gr3" 
  location            = "West Europe"
}

# Create a virtual network
resource "azurerm_virtual_network" "b3-gr3_vnet" {
  name                = "b3-gr3-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = local.resource_group_name
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "b3-gr3_snet" {
  name                 = "b3-gr3-snet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.b3-gr3_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "b3-gr3_public_ip" {
  name                = "b3-gr3-public-ip"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "b3-gr3-devops"
}

# Create a network interface with the public IP address and subnet
resource "azurerm_network_interface" "b3-gr3_nic" {
  name                = "b3-gr3-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "b3-gr3-nic-config"
    subnet_id                     = azurerm_subnet.b3-gr3_snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.b3-gr3_public_ip.id
  }
}

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "b3-gr3_vm" {
  name                 = "b3-gr3-vm"
  resource_group_name  = local.resource_group_name
  location             = local.location
  size                 = "Standard_DS2_v2"
  admin_username       = "azureuser"
  network_interface_ids = [azurerm_network_interface.b3-gr3_nic.id]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/b3-gr3/providers/Microsoft.Compute/images/b3-gr3_linux_image"

  computer_name                    = "b3-gr3-vm"
  disable_password_authentication  = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Create a network security group
resource "azurerm_network_security_group" "b3-gr3_nsg" {
  name                = "b3-gr3-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
}

# Create a network security rule to allow HTTP traffic
resource "azurerm_network_security_rule" "b3-gr3_http" {
  name                        = "b3-gr3-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.b3-gr3_nsg.name
}

# Associate the network security group with the network interface
resource "azurerm_network_interface_security_group_association" "b3-gr3_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.b3-gr3_nic.id
  network_security_group_id = azurerm_network_security_group.b3-gr3_nsg.id
}

# Output for the Fully Qualified Domain Name (FQDN)
output "public_ip_fqdn" {
  value = azurerm_public_ip.b3-gr3_public_ip.fqdn
  description = "The fully qualified domain name (FQDN) of the VM"
}