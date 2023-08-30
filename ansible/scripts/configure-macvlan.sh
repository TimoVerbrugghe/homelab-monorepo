#!/bin/bash
ansible-playbook -vvv \
     -i ../inventory/hosts.yaml \
     --limit "aelita.home.timo.be" \
     ../playbooks/configure-macvlan.yml