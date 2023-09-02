#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,forestsector.home.timo.be \
     ../playbooks/proxmox-host-setup.yml