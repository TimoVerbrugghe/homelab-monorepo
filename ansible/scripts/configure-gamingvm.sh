#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     ../playbooks/gamingvm-setup.yml