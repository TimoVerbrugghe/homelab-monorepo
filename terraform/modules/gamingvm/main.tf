## Proxmox VM Create

# Create Gaming VM
resource "proxmox_vm_qemu" "create_gamingvm" {
    
    for_each = {
        for index, vm in var.vm_configs:
        vm.vm_name => vm
    }

    # VM General Settings
    target_node = "${each.value.node}"
    name = "${each.value.vm_name}"
    bios = "ovmf"
    onboot = false

    clone = "${var.template_name}"
    
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
}