#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,sectorfive.home.timo.be \
     ../playbooks/add-public-keys-proxmox.yml