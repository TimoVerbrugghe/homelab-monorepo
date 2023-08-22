#!/bin/bash
# Do a full configuration across several proxmox nodes & setup Aelita VM

ansible-playbook \
     -i inventory/hosts.ini \
     playbooks/full-proxmox-setup.yml