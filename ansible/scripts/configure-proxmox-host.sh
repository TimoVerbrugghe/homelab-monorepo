#!/bin/sh
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,proxmox\
     ../playbooks/proxmox-host-setup.yaml