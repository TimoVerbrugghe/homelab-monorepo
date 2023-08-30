#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit "aelita.home.timo.be" \
    ../playbooks/certbot-renewal.yml