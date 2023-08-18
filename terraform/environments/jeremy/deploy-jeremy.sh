#!/bin/bash
terraform init
terraform apply -var-file=<(cat ./jeremy.tfvars ../proxmox.tfvars)