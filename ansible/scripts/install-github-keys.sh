#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit sectorfive.local.timo.be,localhost \
     -e "github_username=TimoVerbrugghe" \
     ../playbooks/install-github-keys.yml