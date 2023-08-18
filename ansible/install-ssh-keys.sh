#!/bin/bash
ansible-playbook -vvv \
     -i ulrich.timo.local, \
     -e "ansible_user=root ansible_password=proxmox github_username=TimoVerbrugghe" \
     playbooks/install-ssh-keys.yml