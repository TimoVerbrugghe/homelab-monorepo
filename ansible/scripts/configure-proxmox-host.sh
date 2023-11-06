#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,sectorfive.local.timo.be,forestsector.local.timo.be,mountainsector.local.timo.be,icesector.local.timo.be \
     ../playbooks/proxmox-host-setup.yml