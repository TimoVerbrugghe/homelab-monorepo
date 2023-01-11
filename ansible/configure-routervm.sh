#!/bin/bash
ansible-playbook -vvv \
    -i inventory/hosts.ini \
    playbooks/routervm.yml