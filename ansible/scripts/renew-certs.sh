#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.ini \
    -e "ansible_user=aelita" \
    --limit "aelita.home.timo.be" \
    ../playbooks/certbot-renewal.yml