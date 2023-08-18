github_username = "timoverbrugghe"
template_name = "ubuntu-lxc"
lxc_storage = "local-zfs"
lxc_networkbridge = "vmbr0"

lxc_configs = [ {
    lxc_macaddress = "0A:00:00:00:00:02"
    lxc_memory = 12288
    lxc_name = "jeremy"
    node = "ulrich"
    lxc_disksize = "64G"
} ]
