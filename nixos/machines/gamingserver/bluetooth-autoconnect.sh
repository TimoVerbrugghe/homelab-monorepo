#!/bin/bash

# Specify the MAC address you want to check
mac_address="00:11:22:33:44:55"

# Check if the device is already connected
connected=$(bluetoothctl info $mac_address | grep "Connected: yes")

if [ -n "$connected" ]; then
    echo "Device is already connected"
    exit 0
else
    echo "Device is not connected, trying to connect..."
    
    # Connect to the device
    bluetoothctl connect $mac_address
    
    # Check if the connection was successful
    connected=$(bluetoothctl info $mac_address | grep "Connected: yes")
    
    if [ -n "$connected" ]; then
        echo "Device connected successfully"
        exit 0
    else
        echo "Failed to connect to the device"
    fi
fi