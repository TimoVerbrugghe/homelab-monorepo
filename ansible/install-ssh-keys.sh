#!/bin/bash
ansible-playbook -vvv \
     -i 192.168.0.20, \
     -e "ansible_user=root ansible_password=proxmox" \
     playbooks/install-ssh-keys.yml