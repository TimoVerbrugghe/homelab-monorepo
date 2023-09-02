#!/bin/bash

# Start ansible playbook to set up ubuntu cloudinit template on proxmox. Make sure that inventory contains proxmox ip, username, api token (see group_vars)

ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit sectorfive.home.timo.be \
     ../playbooks/proxmox-igpu-passthrough.yml