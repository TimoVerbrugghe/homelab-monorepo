#!/bin/bash
terraform init
terraform apply -var-file=<(cat ./cloudinit-prod.tfvars ../proxmox.tfvars)