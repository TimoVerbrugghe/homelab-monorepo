#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit vm,localhost \
     -e "github_username=TimoVerbrugghe" \
     ../playbooks/install-ssh-keys.yml