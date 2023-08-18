github_username = "timoverbrugghe"
template_name = "ubuntu-cloud"
vm_storage = "local-zfs"
vm_networkbridge = "vmbr0"

vm_configs = [ {
    vm_cores = 2
    vm_ipaddress = "192.168.0.25"
    vm_memory = 2048
    vm_name = "ulrich"
    node = "proxmox"
}, {
    vm_cores = 2
    vm_ipaddress = "192.168.0.26"
    vm_memory = 2048
    vm_name = "odd"
    node = "proxmox"
}, {
    vm_cores = 2
    vm_ipaddress = "192.168.0.27"
    vm_memory = 2048
    vm_name = "yumi"
    node = "proxmox"
} ]
