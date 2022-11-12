# Proxmox Full-Clone
# ---
# Create a new VM from a clone

data "http" "sshkeys" {
    url = "https://github.com/${var.github_username}.keys"
}

resource "proxmox_vm_qemu" "create_cloud_init_vm" {
    
    # VM General Settings
    target_node = "proxmox"
    name = "${var.vm_name}"
    desc = "${var.vm_description}"
    bios = "ovmf"

    # VM Advanced General Settings
    onboot = true 

    # VM OS Settings
    clone = "${var.template_name}"

    # VM System Settings
    # agent = 1
    
    # VM CPU Settings
    cores = "${var.vm_cores}"
    sockets = 1
    cpu = "host"    
    
    # VM Memory Settings
    memory = "${var.vm_memory}"

    # VM Network Settings
    network {
        bridge = "${var.vm_networkbridge}"
        model  = "virtio"
    }

    disk {
        storage = "${var.vm_storage}"
        type = "scsi"
        size = "${var.vm_disksize}"
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    ipconfig0 = "ip=${var.vm_ipaddress}/24,gw=192.168.0.1"
    
    # (Optional) Default User
    ciuser = "${var.vm_ciuser}"
    cipassword = "${var.vm_cipassword}"
    
    # (Optional) Add your SSH KEY
    sshkeys = tostring(data.http.sshkeys.response_body)
}