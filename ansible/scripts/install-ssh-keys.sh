#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit forestsector.home.timo.be,localhost \
     -e "ansible_user=root ansible_password=proxmox github_username=TimoVerbrugghe" \
     ../playbooks/install-ssh-keys.yml