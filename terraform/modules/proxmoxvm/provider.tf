terraform {
    required_version = ">= 0.13.0"

    required_providers {
        http = {
            source = "hashicorp/http"
        }
        proxmox = {
            source = "telmate/proxmox"
        }
    }
}