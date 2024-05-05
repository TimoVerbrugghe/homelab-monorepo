#!/bin/sh
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,forestsector.local.timo.be \
     ../playbooks/proxmox-host-setup.yml