#!/bin/bash
ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,sectorfive.local.timo.be \
     ../playbooks/gamingvm-setup.yml