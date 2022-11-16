#############################################################
# Proxmox variables
#############################################################
variable "proxmox_hostname" {
  description = "Proxmox host address (e.g. https://192.168.1.1:8006)"
  type = string
}

variable "proxmox_username" {
  description = "Proxmox username (e.g. root@pam)"
  type = string
}

variable "proxmox_api_token_secret" {
  description = "secret of proxmox api token"
  type = string
}

variable "proxmox_node_name" {
  description = "Proxmox node"
  type = string
}

variable "proxmox_insecure_skip_tls_verify" {
  description = "Skip TLS verification?"
  type = bool
  default = true
}

#############################################################
# Template variables
#############################################################
variable "template_description" {
  description = "Template description"
  type = string
  default = "Windows VM"
}

variable "vm_id" {
  description = "VM template ID"
  type = number
}

variable "vm_name" {
  description = "VM name"
  type = string
  default = "windowsvm"
}

variable "vm_storage_pool" {
  description = "Storage where template will be stored"
  type = string
  default = "local-zfs"
}

variable "storage_pool_type" {
  type = string
  default = "zfspool"
}

variable "vm_cores" {
  description = "VM amount of memory"
  type = number
  default = 2
}

variable "vm_memory" {
  description = "VM amount of memory"
  type = number
  default = 2048
}

variable "iso_url" {
  description = "ISO image download link"
  type = string
  default = ""
}

variable "iso_storage_pool" {
  description = "Proxmox storage pool onto which to upload the ISO file."
  type = string
  default = ""
}

variable "iso_checksum" {
  default = ""
  type = string
  description = " Checksum of the ISO file"
}

variable "iso_file" {
  description = "Location of ISO file on the server. E.g. local:iso/<filename>.iso"
  type = string
  default = ""
}

variable "pool" {
  description = " Name of resource pool to create virtual machine in"
  type = string
  default = ""
}

#############################################################
# Download variables
#############################################################
variable "windows_iso_url" {
  type = string
}

variable "windows_iso_checksum" {
  type = string
}

variable "virtiowin_url" {
  type = string
}

variable "virtiowin_checksum" {
  type = string
  # There is no checksum url provided for the virtiowin downloads and the latest virtio-win.iso changes fast
  default = "none"
}


#############################################################
# OS Settings
#############################################################
variable "winrm_password" {
  type    = string
  default = "administrator"
}

variable "winrm_username" {
  type    = string
  default = "Administrator"
}

variable "winrm_hostname" {
  type    = string
  default = "WindowsVM"
}