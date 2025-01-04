#!/bin/bash

# This environment variable is necessary to avoid fork errors in ansible 
# For more information, see https://github.com/ansible/ansible/issues/76322
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

ansible-playbook \
     -i ../inventory/hosts.yaml \
     --limit localhost,sectorfive.local.timo.be,gamingvm \
     ../playbooks/gamingvm-setup.yaml