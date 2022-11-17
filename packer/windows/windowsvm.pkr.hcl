source "proxmox-iso" "windowsvm" {
    # Proxmox connection configuration

    proxmox_url = "https://${var.proxmox_hostname}:${var.proxmox_port}/api2/json"
    insecure_skip_tls_verify = "${var.proxmox_insecure_skip_tls_verify}"
    username = "${var.proxmox_username}"
    token = "${var.proxmox_api_token_secret}"
    node = "${var.proxmox_node_name}"

    # General VM configuration
    vm_name = "${var.vm_name}"
    vm_id = "${var.vm_id}"
    memory = "${var.vm_memory}"
    sockets = 1
    cores = "${var.vm_cores}"
    cpu_type = "host"
    machine = "q35"
    bios = "ovmf"
    os = "win11"

    // # Efidisk location
    efidisk = "${var.vm_storage_pool}"

    // # Template configuration
    template_name = "${var.vm_name}"
    template_description = "${var.template_description}"

    // # Network configuration
    network_adapters {
        model   = "virtio"
        bridge  = "vmbr0"
    }

    // # Disks controller
    scsi_controller = "virtio-scsi-pci"

    disks {
        type = "scsi"
        disk_size = "64G"
        storage_pool = "${var.vm_storage_pool}"
        storage_pool_type = "${var.storage_pool_type}"
    }

    // # Add the windows 11 iso
    iso_file = "local:iso/windows11.iso"
    // iso_file = "${var.windows_iso_url}"
    // iso_checksum = "${var.windows_iso_checksum}"
    // iso_storage_pool = "local"
    unmount_iso = true
    qemu_agent = true

    // # Add additional files for starting windows ISO

    additional_iso_files {
        device = "sata0"
        iso_file = "local:iso/virtiowin.iso"
        // iso_url = "${var.virtiowin_url}"
        // iso_checksum = "${var.virtiowin_checksum}"
        unmount = true
        iso_storage_pool = "local"
    }

    additional_iso_files {
        device = "sata1"
        cd_files = ["./autounattend.xml", "./configurewinrm.ps1"]
        cd_label = "WIN_AUTOINSTALL"
        iso_storage_pool = "local"
        unmount = true
    }

    onboot = false
    boot = "order=scsi0;ide2;net0"

    // # Type in something when the boot starts so we can skip "Press any button to boot from CD or DVD"
    boot_wait = "10s"
    boot_command = [
        "<spacebar><spacebar>"
    ]

    communicator         = "winrm"
    winrm_insecure       = true
    winrm_password       = "${var.winrm_password}"
    winrm_use_ssl        = true
    winrm_username       = "${var.winrm_username}"
    // winrm_host           = "${var.winrm_host}"

}

build {
    sources = [
        "source.proxmox-iso.windowsvm"
    ]

    # TO DO See if I'm going to either change something in here or leave it up to ansible
    provisioner "powershell" {
        inline = [
            "mkdir c:\\Packer",
            "Clear-Host",
            "Write-Host \"Running test to see if PowerShell works\"",
            "Read-Host -Prompt \"Press any key to continue\""
        ]
    }

    post-processor "shell-local" { 
        inline = [
            "ssh root@${var.proxmox_hostname} qm set ${var.vm_id} --tpmstate0 local-zfs:1,version=v2.0",
            "ssh root@${var.proxmox_hostname} qm set ${var.vm_id} --balloon 0"
        ]
    }
}


