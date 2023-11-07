#!/bin/bash
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit k3scluster,localhost \
    ../playbooks/test.yml