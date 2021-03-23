# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "PAMResourceGroup"
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "PAMVnet"
  address_space       = ["192.168.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "PAMSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.1.0/24"]
}


# Create public IP for Windows10
resource "azurerm_public_ip" "W10_publicip" {
  name                = "W10_publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create public IP for Ubuntu
resource "azurerm_public_ip" "Ubuntu_publicip" {
  name                = "Ubuntu_publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create public IP for WS
resource "azurerm_public_ip" "WServer_publicip" {
  name                = "WServer_publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "PAMNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface for Windows10
resource "azurerm_network_interface" "Windows10_nic" {
  name                = "Windows10_nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "PAMNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.W10_publicip.id
  }
}

# Create network interface for Ubuntu
resource "azurerm_network_interface" "Ubuntu_nic" {
  name                = "Ubuntu_nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "PAMNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.Ubuntu_publicip.id
  }
}

# Create network interface for WS
resource "azurerm_network_interface" "WindowsServer_nic" {
  name                = "WindowsServer_nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "PAMNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = "192.168.1.10"
    public_ip_address_id          = azurerm_public_ip.WServer_publicip.id
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}



# Create Ubuntu virtual machine
resource "azurerm_linux_virtual_machine" "UbuntuVM" {
  name                  = var.linux_virtual_machine_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.Ubuntu_nic.id]
  size                  = var.azure_size

  os_disk {      
    name                 = "${var.linux_virtual_machine_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = var.linux_virtual_machine_name
  admin_username                  = var.linux_virtual_machine_admin_username
  admin_password                  = var.linux_virtual_machine_admin_password
  disable_password_authentication = false

 
  admin_ssh_key {
    username   = var.linux_virtual_machine_admin_username
    public_key = tls_private_key.example_ssh.public_key_openssh
  }


}

# Create Windows 10 Virtual Machine
resource "azurerm_windows_virtual_machine" "Windows10VM" {
  name                  = var.windows-10-vm-hostname
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.azure_size
  network_interface_ids = [azurerm_network_interface.Windows10_nic.id]
  
  computer_name         = var.windows-10-vm-hostname
  admin_username        = var.windows-10-vm-admin-username
  admin_password        = var.windows-10-vm-admin-password
  os_disk {
    name                 = "${var.windows-10-vm-hostname}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "19h2-pro-g2"
    version   = "latest"
  }
  enable_automatic_updates = true
  provision_vm_agent       = true
}

# Create Windows Server Virtual Machine
resource "azurerm_windows_virtual_machine" "WindowsServerVM" {
  name                  = var.windows-server-vm-hostname
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.azure_size
  network_interface_ids = [azurerm_network_interface.WindowsServer_nic.id]
  
  computer_name         = var.windows-server-vm-hostname
  admin_username        = var.windows-server-vm-admin-username
  admin_password        = var.windows-server-vm-admin-password
  os_disk {
    name                 = "${var.windows-server-vm-hostname}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  enable_automatic_updates = true
  provision_vm_agent       = true
}


# Auto shutdown for Windows10VM
resource "azurerm_dev_test_global_vm_shutdown_schedule" "Windows10VM-AutoShutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.Windows10VM.id
  
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.daily_recurrence_time
  timezone              = var.timezone

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
  }
}

# Auto shutdown for UbuntuVM
resource "azurerm_dev_test_global_vm_shutdown_schedule" "UbuntuVM-AutoShutdown" {
  virtual_machine_id = azurerm_linux_virtual_machine.UbuntuVM.id
  
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.daily_recurrence_time
  timezone              = var.timezone

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
  }
}

# Auto shutdown for WindowsServerVM
resource "azurerm_dev_test_global_vm_shutdown_schedule" "WindowsServerVM-AutoShutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.WindowsServerVM.id
  
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.daily_recurrence_time
  timezone              = var.timezone

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
  }
}
