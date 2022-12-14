#!/bin/bash

# Start ansible playbook to set up ubuntu cloudinit template on proxmox. Make sure that inventory contains proxmox ip, username, api token (see group_vars)

ansible-playbook -vvv \
     -i inventory/hosts.ini \
     playbooks/proxmox-cloud-init-template.yml