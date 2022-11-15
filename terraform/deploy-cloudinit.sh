#!/bin/sh
terraform apply -target=module.cloudinit -var-file=environments/cloudinit.tfvars