#!/bin/bash
# Do a full configuration across several proxmox nodes & setup Aelita VM

ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit ulrich.local.timo.be,odd.local.timo.be,aelita.local.timo.be \
     ../playbooks/enable-swap.yml