#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.ini \
     -e "ansible_user=root ansible_password=proxmox github_username=TimoVerbrugghe" \
     ../playbooks/install-ssh-keys.yml