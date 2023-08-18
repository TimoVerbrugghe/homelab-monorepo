#!/bin/bash
terraform init
terraform apply -var-file=<(cat ./aelita.tfvars ../proxmox.tfvars)