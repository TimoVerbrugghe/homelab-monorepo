#!/bin/sh
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,icesector.local.timo.be,mountainsector.local.timo.be \
     ../playbooks/proxmox-host-setup.yaml