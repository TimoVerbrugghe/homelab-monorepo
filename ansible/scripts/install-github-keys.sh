#!/bin/sh
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit proxmox,localhost \
     -e "github_username=TimoVerbrugghe" \
     -k \
     ../playbooks/install-github-keys.yaml