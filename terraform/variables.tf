# Terraform variables

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "github_username" {
    type = string
}

variable "vm_ipaddress" {
    type = string
}

variable "vm_ciuser" {
    type = string
    default = "admin"
} 

variable "vm_cipassword" {
    type = string
    default = "admin"
}

variable "template_name" {
    type = string
}

variable "vm_cores" {
    type = number
    default = 1
}

variable "vm_memory" {
    type = number
    default = 2048
}

variable "vm_networkbridge" {
    type = string
    default = "vmbr0"
}

variable "vm_disksize" {
    type = string
    default = "20G"
}

variable "vm_storage" {
    type = string
    default = "local-zfs"
}

variable "vm_name" {
    type = string
}

variable "vm_description" {
    type = string
    default = ""
}

