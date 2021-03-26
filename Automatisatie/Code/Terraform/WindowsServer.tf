# Create public IP for WS
resource "azurerm_public_ip" "WServer_publicip" {
  name                = "WServer_publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Associate NSG with the NIC of WS
resource "azurerm_network_interface_security_group_association" "WSNICNSG" {
  network_interface_id      = azurerm_network_interface.WindowsServer_nic.id
  network_security_group_id = azurerm_network_security_group.Windows_nsg.id
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
/*
  os_profile_windows_config {
    provision_vm_agent = true
    winrm {
      protocol = "http"
  }
  }


  # Auto-Login's required to configure WinRM
  additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.windows-server-vm-admin-password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.windows-server-vm-admin-username}</Username></AutoLogon>"
  }  
  

  # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
  additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("FirstLogonCommands.xml")
  }


  connection {
    type     = "winrm"
    user     = var.windows-server-vm-admin-username
    password = var.windows-server-vm-admin-password
    host     = self.public_ip_address
    https    = false
    insecure = true
    timeout  = 20
    port = 5985

  }
  
  provisioner "file" {
    source      = var.ad-ps-file
    destination = "C:/${var.ad-ps-file}"
  }

  provisioner "file" {
    source      = var.ad-users-file
    destination = "C:/${var.ad-users-file}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -ExecutionPolicy Bypass -File C:/${var.ad-users-file}"
    ]
  }*/
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

