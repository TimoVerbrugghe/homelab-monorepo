#!/bin/bash
terraform init
terraform apply -target=module.cloudinit -var-file=<(cat environments/k3scluster.tfvars environments/proxmox.tfvars)