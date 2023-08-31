#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit aelita.home.timo.be,ulrich.home.timo.be,odd.home.timo.be \
    ../playbooks/certbot-renewal.yml