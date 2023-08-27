#!/bin/bash
ansible-playbook \
     -i "10.10.10.4","10.10.10.5","10.10.10.6" \
     -e "ansible_user=root ansible_password=proxmox github_username=TimoVerbrugghe" \
     playbooks/install-ssh-keys.yml