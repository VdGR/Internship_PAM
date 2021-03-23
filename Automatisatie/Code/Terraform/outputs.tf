output "vm_id_Ubuntu" {
  value = azurerm_linux_virtual_machine.UbuntuVM.id
}

output "Windows10_id" {
  value = azurerm_windows_virtual_machine.Windows10VM.id
}


output "vm_ip" {
  value = azurerm_linux_virtual_machine.UbuntuVM.public_ip_address
}

output "Windows10_ip" {
  value = azurerm_windows_virtual_machine.Windows10VM.public_ip_address
}


output "tls_private_key" { 
  value = tls_private_key.example_ssh.private_key_pem 
}