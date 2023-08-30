#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     ../playbooks/prep-gamingvm.yml