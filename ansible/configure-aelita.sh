#!/bin/bash
ansible-playbook \
    -i inventory/hosts.ini \
    playbooks/aelita.yml