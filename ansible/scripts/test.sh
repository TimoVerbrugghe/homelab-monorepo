#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit k3stest.local.timo.be \
    ../playbooks/debug/check-vars.yml