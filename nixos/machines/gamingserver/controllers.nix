{ config, pkgs, ... }:

let
  bluetoothReconnectScript = ''
    #!/bin/bash

    # Specify the MAC address you want to check
    mac_address="28:C5:D2:EF:60:77"

    # Check if the device is already connected
    connected=$(bluetoothctl info $mac_address | grep "Connected: yes")

    if [ -n "$connected" ]; then
        echo "Device is already connected"
        exit 0
    else
        echo "Device is not connected, trying to connect..."
        
        # Connect to the device
        bluetoothctl connect $mac_address

        # Sleep 5 to wait for connection
        sleep 5
        
        # Check if the connection was successful
        connected=$(bluetoothctl info $mac_address | grep "Connected: yes")
        
        if [ -n "$connected" ]; then
            echo "Device connected successfully"
            exit 0
        else
            echo "Failed to connect to the device"
            exit 1
        fi
    fi
  '';
in

{

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # AX200 Bluetooth module
  boot.kernelModules = [ "btintel" ];

  services.udev.extraRules = ''
    ACTION=="remove", SUBSYSTEM=="bluetooth", ATTR{address}=="28:C5:D2:EF:60:77", RUN+="systemd start bluetooth-reconnect.service"
  '';

  systemd.services.switch-procontroller-bluetooth-reconnect = {
    description = "Bluetooth Reconnect Service for Switch Pro Controller";
    after = [ "bluetooth.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${bluetoothReconnectScript}'";
      Restart = "on-failure";
    };
  };

}