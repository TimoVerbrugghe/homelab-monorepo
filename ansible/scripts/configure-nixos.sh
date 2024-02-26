#!/bin/sh
ansible-playbook -vvv \
     -i "10.10.10.23," \
     -e "tailscaleAuthkey=" \
     -e "nixosFlake=nixos" \
     -e "ansible_username=nixos" \
     -e "ansible_password=nixos" \
     -e "ansible_become_password=nixos" \
     ../playbooks/configure-nixos.yml