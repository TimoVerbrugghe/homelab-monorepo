#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,mountainsector.home.timo.be \
     ../playbooks/proxmox-host-setup.yml