#!/bin/bash
ansible-playbook \
     -i "10.10.10.23," \
     -e "tailscaleAuthkey=" \
     -e "nixosFlake=nixos" \
     ../playbooks/configure-nixos.yml