#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit k3stest.local.timo.be,localhost \
    ../playbooks/deploy-k3scluster.yaml