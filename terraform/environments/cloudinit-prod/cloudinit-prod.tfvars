github_username = "TimoVerbrugghe"
template_name = "ubuntu-cloud"
vm_storage = "local-btrfs"
vm_networkbridge = "vmbr0"
gateway = "10.10.10.1"
nameserver = "10.10.10.20 10.10.10.21 10.10.10.22"

vm_configs = [ {
    vm_cores = 4
    vm_macaddress = "0A:00:00:00:00:02"
    vm_memory = 12288
    vm_name = "ulrich"
    node = "mountainsector"
    vm_disksize = "64G"
    vm_id = 106
    vm_ipaddress = "10.10.10.8"
}, {
    vm_cores = 4
    vm_macaddress = "0A:00:00:00:00:03"
    vm_memory = 12288
    vm_name = "odd"
    node = "icesector"
    vm_disksize = "64G"
    vm_id = 107
    vm_ipaddress = "10.10.10.9"
}
]
