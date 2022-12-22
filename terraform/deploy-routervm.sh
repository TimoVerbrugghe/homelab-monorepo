#!/bin/bash
terraform init
terraform apply -target=module.cloudinit -var-file=<(cat environments/routervm.tfvars environments/proxmox.tfvars)