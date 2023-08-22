#!/bin/bash
ansible-playbook \
     -i "10.10.10.7","10.10.10.8" \
     -e "ansible_user=root ansible_password=proxmox github_username=TimoVerbrugghe" \
     playbooks/install-ssh-keys.yml