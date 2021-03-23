variable "location" {
  type        = string
  description = "location"
}

variable "azure_size" {
  type        = string
  description = "Size of Azure"
  
}


variable "storage_account_type" {
  type        = string
  description = "Storage account type"
  
}

variable "linux_virtual_machine_name" {
  type        = string
  description = "Linux VM name in Azure"
}

variable "linux_virtual_machine_computer_name" {
  type        = string
  description = "Linux VM computername"
}

variable "linux_virtual_machine_admin_username" {
  type        = string
  description = "Linux VM username"
}

variable "linux_virtual_machine_admin_password" {
  type        = string
  description = "Linux VM password"
}

variable "windows-10-vm-hostname" {
  type        = string
  description = "Name of Windows10 VM"
}

variable "windows-10-vm-admin-username" {
  type        = string
  description = "Username of Windows10 VM"
}

variable "windows-10-vm-admin-password" {
  type        = string
  description = "Password of Windows10 VM"
}





