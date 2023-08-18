module "proxmox-lxc" {
    source = "../../modules/proxmox-lxc"
    
    github_username = "${var.github_username}"

    template_name = "${var.template_name}"
    lxc_configs = "${var.lxc_configs}"
    lxc_storage = "${var.lxc_storage}"
    lxc_networkbridge = "${var.lxc_networkbridge}"
}