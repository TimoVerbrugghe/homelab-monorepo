terraform {

    required_version = ">= 0.13.0"

    required_providers {
        proxmox = {
            source = "telmate/proxmox"
        }
        http = {
            source = "hashicorp/http"
        }
    }
}

module "proxmox_settings" {
    source = "./modules/proxmoxsettings"
}

provider "proxmox" {

    pm_api_url = "${module.proxmox_settings.proxmox_api_url}"
    pm_api_token_id = "${module.proxmox_settings.proxmox_api_token_id}"
    pm_api_token_secret = "${module.proxmox_settings.proxmox_api_token_secret}"

    # (Optional) Skip TLS Verification
    pm_tls_insecure = true

}