#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit proxmox \
     ../playbooks/install-ssh-keys.yml