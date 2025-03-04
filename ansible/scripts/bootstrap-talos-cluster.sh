#!/bin/sh
ansible-playbook \
    -i ../inventory/hosts.yaml \
    --limit localhost,taloshosts \
    ../playbooks/bootstrap-talos-k8s-cluster.yaml