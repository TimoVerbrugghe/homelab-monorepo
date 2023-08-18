github_username = "TimoVerbrugghe"
template_name = "ubuntu-cloud"
vm_storage = "local-zfs"
vm_networkbridge = "vmbr0"

vm_configs = [ {
    vm_cores = 4
    vm_macaddress = "0A:00:00:00:00:01"
    vm_memory = 12288
    vm_name = "aelita"
    node = "ulrich"
    vm_disksize = "64G"
} ]
