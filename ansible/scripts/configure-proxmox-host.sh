#!/bin/sh
# -u: remote SSH user
# -k / --ask-pass: prompt for SSH password
# (add -K if you also need a privilege escalation/become password)

ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,forestsector.local.timo.be \
     -u root \
     -k \
     ../playbooks/proxmox-host-setup.yaml