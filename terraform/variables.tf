# Terraform variables
variable "github_username" {
    type = string
    default = ""
}

variable "template_name" {
    type = string
    default = ""
}

variable "vm_networkbridge" {
    type = string
    default = "vmbr0"
}

variable "vm_storage" {
    type = string
    default = "local-zfs"
}

variable "gateway" {
    type = string
    default = "192.168.0.1"
}

variable "vm_configs" {
    type = list(object({
        vm_name = string
        vm_description = optional(string, "")
        vm_ipaddress = string
        vm_cores = optional(number, 1)
        vm_memory = optional(number, 2048)
        vm_disksize = optional(string, "40G")
        node = optional(string, "proxmox")
    }))
}

variable "proxmox_api_token_id" {
    type = string
    default = "root@pam!terraform"
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "proxmox_api_url" {
    type = string
    default = "https://proxmox.timo.be/api2/json"
}

variable "proxmox_tls_insecure" {
    type = string
    default = true
}