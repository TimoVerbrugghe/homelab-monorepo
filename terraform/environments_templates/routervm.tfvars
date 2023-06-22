github_username = "timoverbrugghe"
template_name = "ubuntu-cloud"
vm_storage = "local-zfs"
vm_networkbridge = "vmbr1"

vm_configs = [ {
    vm_cores = 4
    vm_ipaddress = "10.10.10.3"
    vm_memory = 8192
    vm_name = "jeremy"
    node = "routerpve"
    vm_disksize = "400G"
} ]
