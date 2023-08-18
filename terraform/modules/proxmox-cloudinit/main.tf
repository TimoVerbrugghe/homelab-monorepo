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
resource "proxmox_vm_qemu" "create_proxmox_vms" {
    
    for_each = {
        for index, vm in var.vm_configs:
        vm.vm_name => vm
    }
    
    define_connection_info = false

    # VM General Settings
    target_node = "${each.value.node}"
    name = "${each.value.vm_name}"
    bios = "ovmf"
    clone = "${var.template_name}"
    full_clone = true
    onboot = true
    os_type = "cloud-init"
    tablet = false
    agent = 1
    boot = "order=scsi0;net0"
    hastate = "started"
    scsihw = "virtio-scsi-pci"
    
    # CPU Settings
    cores = "${each.value.vm_cores}"
    sockets = 1
    cpu = "host"    
    
    # Memory Settings
    memory = "${each.value.vm_memory}"
    balloon = 0

    # Network Settings
    network {
        bridge = "${var.vm_networkbridge}"
        model  = "virtio"
        macaddr = "${each.value.vm_macaddress}"
    }

    # Disk Settings
    disk {
        storage = "${var.vm_storage}"
        type = "scsi"
        size = "${each.value.vm_disksize}"
    }

    # Cloud-Init settings
    ipconfig0 = "ip=dhcp,ip6=dhcp"
    ciuser = "${each.value.vm_name}"
    cipassword = "${each.value.vm_name}"
    sshkeys = tostring(data.http.sshkeys.response_body)
}