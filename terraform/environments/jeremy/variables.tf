# Terraform variables
variable "github_username" {
    type = string
    default = "TimoVerbrugghe"
}

variable "template_name" {
    type = string
    default = "ubuntu-lxc"
}

variable "lxc_networkbridge" {
    type = string
    default = "vmbr0"
}

variable "lxc_storage" {
    type = string
    default = "local-zfs"
}

variable "lxc_configs" {
    type = list(object({
        lxc_name = string
        lxc_description = optional(string, "")
        lxc_macaddress = string
        lxc_cores = optional(number, 1)
        lxc_memory = optional(number, 2048)
        lxc_disksize = optional(string, "40G")
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