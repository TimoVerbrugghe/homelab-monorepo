#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit k3scluster,localhost \
    ../playbooks/deploy-k3scluster.yml