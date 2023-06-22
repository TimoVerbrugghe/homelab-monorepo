module "cloudinit" {
    source = "./modules/cloudinit"
    
    github_username = "${var.github_username}"

    template_name = "${var.template_name}"
    vm_configs = "${var.vm_configs}"
    vm_storage = "${var.vm_storage}"
    vm_networkbridge = "${var.vm_networkbridge}"
}

# module "gamingvm" {
#     source = "./modules/gamingvm"
# }