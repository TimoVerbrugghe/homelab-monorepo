#!/bin/bash
ansible-playbook\
    -i ../inventory/hosts.yaml \
    ../playbooks/igpuvm.yml