# Proxmox Cloud-Init Full clone

# Import ssh keys
data "http" "sshkeys" {
    url = "https://github.com/${var.github_username}.keys"

    # Check if SSH keys got downloaded correctly
    lifecycle {
        postcondition {
            condition     = contains([200, 201, 204], self.status_code)
            error_message = "SSH keys not found to apply in cloud-init template"
        }
    }
}

# Create Cloud Init VMs
resource "proxmox_lxc" "create_proxmox_lxcs" {

    for_each = {
        for index, lxc in var.lxc_configs:
        lxc.lxc_name => lxc
    }

    full = true
    target_node = "${each.value.node}"
    hostname    = "${each.value.lxc_name}"
    clone       = 9999
    password    = "${each.value.lxc_name}"
    onboot      = true

    // Terraform will crash without rootfs defined
    rootfs {
        storage = "${var.lxc_storage}"
        size    = "${each.value.lxc_disksize}"
    }

    network {
        name = "eth0"
        bridge = "${var.lxc_networkbridge}"
        hwaddr = "${each.value.lxc_macaddress}"
        ip = "dhcp"
    }
}