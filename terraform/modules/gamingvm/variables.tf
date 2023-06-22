# Terraform variables
variable "target_node" {
    type = string
    default = "proxmox"
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
        vm_cores = optional(number, 1)
        vm_memory = optional(number, 2048)
        vm_disksize = optional(string, "40G")
        node = optional(string, "proxmox")
    }))
}