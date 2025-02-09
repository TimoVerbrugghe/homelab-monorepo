#!/bin/sh
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit azurenixbuilder.azure.timo.be \
     -u azureuser \
     --private-key /home/Timo/.ssh/azurenixbuild_key.pem \
     ../playbooks/configure-azurenixbuilder.yaml