# Proxmox Full-Clone
# ---
# Create a new VM from a clone

data "http" "sshkeys" {
    url = "https://github.com/${var.github_username}.keys"
}

resource "proxmox_vm_qemu" "create_cloud_init_vm" {
    
    for_each = {
        for index, vm in var.vm_configs:
        vm.vm_name => vm
    }
    
    # VM General Settings
    target_node = "proxmox"
    name = "${each.value.vm_name}"
    bios = "ovmf"
    clone = "${var.template_name}"
    onboot = true # boot when VM is created
    os_type = "cloud-init"
    
    # CPU Settings
    cores = "${each.value.vm_cores}"
    sockets = 1
    cpu = "host"    
    
    # Memory Settings
    memory = "${each.value.vm_memory}"

    # Network Settings
    network {
        bridge = "${var.vm_networkbridge}"
        model  = "virtio"
    }

    # Disk Settings
    disk {
        storage = "${var.vm_storage}"
        type = "scsi"
        size = "${each.value.vm_disksize}"
    }

    # Cloud-Init settings
    ipconfig0 = "ip=${each.value.vm_ipaddress}/24,gw=${var.gateway}"
    ciuser = "${each.value.vm_name}"
    cipassword = "${each.value.vm_name}"
    sshkeys = tostring(data.http.sshkeys.response_body)
}