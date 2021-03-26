# Create public IP for Windows10
resource "azurerm_public_ip" "W10_publicip" {
  name                = "W10_publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Associate NSG with the NIC of W10
resource "azurerm_network_interface_security_group_association" "W10NICNSG" {
  network_interface_id      = azurerm_network_interface.Windows10_nic.id
  network_security_group_id = azurerm_network_security_group.Windows_nsg.id
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
