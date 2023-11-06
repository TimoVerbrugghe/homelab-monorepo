github_username = "timoverbrugghe"
template_name = "ubuntu-cloud"
vm_storage = "local-btrfs"
vm_networkbridge = "vmbr0"
gateway = "10.10.10.1"
nameserver = "10.10.10.20 10.10.10.21 10.10.10.22"

vm_configs = [ {
    vm_cores = 2
    vm_macaddress = "0A:00:00:00:00:10"
    vm_memory = 4096
    vm_name = "william"
    node = "sectorfive"
    vm_disksize = "64G"
    vm_id = 110
    vm_ipaddress = "10.10.10.30"
}, {
    vm_cores = 2
    vm_macaddress = "0A:00:00:00:00:11"
    vm_memory = 4096
    vm_name = "tower"
    node = "sectorfive"
    vm_disksize = "64G"
    vm_id = 111
    vm_ipaddress = "10.10.10.31"
}, {
    vm_cores = 2
    vm_macaddress = "0A:00:00:00:00:12"
    vm_memory = 4096
    vm_name = "skidbladnir"
    node = "sectorfive"
    vm_disksize = "64G"
    vm_id = 112
    vm_ipaddress = "10.10.10.32"
} ]