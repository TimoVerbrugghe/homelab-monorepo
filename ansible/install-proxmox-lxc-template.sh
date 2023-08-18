#!/bin/bash
# Download an LXC container, create a new one and start it

# This environment variable needs to be set because one of the tasks is a file lookup on an url which triggers a bug with thread workers in python
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES 

# Hosts should be put under the "proxmox" category

ansible-playbook \
     -i inventory/hosts.ini \
     playbooks/proxmox-lxc-template.yml