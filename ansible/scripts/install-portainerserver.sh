#!/bin/bash
ansible-playbook -vvv \
     -i "10.10.10.7", \
     -e "ansible_user=aelita" \
     ../playbooks/portainerserver-install.yml