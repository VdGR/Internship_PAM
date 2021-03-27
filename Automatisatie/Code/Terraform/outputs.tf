/*
output "Ubuntu_id" {
  value = azurerm_linux_virtual_machine.UbuntuVM.id
}

output "Windows10_id" {
  value = azurerm_windows_virtual_machine.Windows10VM.id
}

output "WindowsServer_id" {
  value = azurerm_windows_virtual_machine.WindowsServerVM.id
}

output "tls_private_key" { 
  value = tls_private_key.Ubuntu_ssh.private_key_pem 
}

*/


resource "local_file" "Ubuntu_private_key" {
    content  = tls_private_key.Ubuntu_ssh.private_key_pem 
    filename = "Ubuntu_private_key.pem"
}

output "Ubuntu_ip" {
  value = azurerm_linux_virtual_machine.UbuntuVM.public_ip_address
}
output "Ubuntu_username" {
  value = azurerm_linux_virtual_machine.UbuntuVM.admin_username
}
output "Ubuntu_password" {
  value = azurerm_linux_virtual_machine.UbuntuVM.admin_password
}



output "Windows10_ip" {
  value = azurerm_windows_virtual_machine.Windows10VM.public_ip_address
}
output "Windows10_username" {
  value = azurerm_windows_virtual_machine.Windows10VM.admin_username
}
output "Windows10_password" {
  value = azurerm_windows_virtual_machine.Windows10VM.admin_password
}


output "WindowsServer_ip" {
  value = azurerm_windows_virtual_machine.WindowsServerVM.public_ip_address
}
output "WindowsServer_username" {
  value = azurerm_windows_virtual_machine.WindowsServerVM.admin_username
}
output "WindowsServer_password" {
  value = azurerm_windows_virtual_machine.WindowsServerVM.admin_password
}




