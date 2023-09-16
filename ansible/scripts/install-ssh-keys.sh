#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit proxmox,localhost \
     -e "github_username=TimoVerbrugghe" \
     ../playbooks/install-ssh-keys.yml