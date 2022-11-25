#! /usr/bin/env bash

# Proxmox always launches scripts with 2 variables, first the VM_ID and secondly the execution phase
# Execution phase is either pre-start, post-start, pre-stop and post-stop
VM_ID=$1;
EXECUTION_PHASE=$2

function enable_cpupinning {
    # Setting proxmox to only use the first core (and its hyperthreaded counterpart) so VM can exclusively use all other cores

    systemctl set-property --runtime -- user.slice AllowedCPUs=0,6
    systemctl set-property --runtime -- system.slice AllowedCPUs=0,6
    systemctl set-property --runtime -- init.scope AllowedCPUs=0,6
}

function disable_cpupinning {
    # Setting proxmox to use all CPU cores
    
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-11
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-11
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-11
}

if [[ "$EXECUTION_PHASE" == "pre-start" ]]; then

    echo "$VM_ID (WindowsVM) is starting up. Setting proxmox to use CPU cores not assigned to this VM exclusively."

    enable_cpupinning

elif [[ "$EXECUTION_PHASE" == "post-stop" ]] then

    echo "$VM_ID (WindowsVM) has shut down. Setting proxmox to use all CPU cores."

    disable_cpupinning

fi
