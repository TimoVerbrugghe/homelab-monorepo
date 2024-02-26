#!/bin/sh
ansible-playbook -vvv \
     -i "10.10.10.23," \
     -e "tailscaleAuthkey=" \
     -e "nixosFlake=nixos" \
     -e "ansible_username=nixos" \
     -e "ansible_pass=nixos" \
     -e "ansible_sudo_pass=nixos" \
     ../playbooks/configure-nixos.yml