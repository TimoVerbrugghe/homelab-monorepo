#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.ini -vvv \
     ../playbooks/prep-gamingvm.yml