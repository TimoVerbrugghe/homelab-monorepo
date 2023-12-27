#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit k3stest.local.timo.be,localhost \
    --ask-become-pass \
    ../playbooks/deploy-k3scluster.yml