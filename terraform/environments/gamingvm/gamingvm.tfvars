template_name = "windowsvm"
vm_storage = "local-btrfs"
vm_networkbridge = "vmbr0"

vm_configs = [ {
    vm_cores = 2
    vm_memory = 2048
    vm_name = "odd"
} ]