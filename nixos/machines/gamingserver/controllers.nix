{ config, pkgs, ... }:

let
  macAddressProController = "28:CF:51:A5:86:6E";
in

{

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # AX200 Bluetooth module
  boot.kernelModules = [ "btintel" ];

  services.udev.extraRules = ''
    ACTION=="remove", SUBSYSTEM=="bluetooth", ATTR{address}=="${macAddressProController}", RUN+="${pkgs.systemd}/bin/systemctl start bluetooth-reconnect.service"
  '';

  systemd.services.switch-procontroller-bluetooth-reconnect = {
    description = "Bluetooth Reconnect Service for Switch Pro Controller";
    after = [ "bluetooth.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart="on-failure";
      Type="oneshot";
    };
    path = with pkgs; [
      bluez
    ];
    enable = true;
    script = ''
      # Check if the device is already connected
      connected=$(bluetoothctl info ${macAddressProController} | grep "Connected: yes")

      while [ -z "$connected" ]; do
          echo "Device is not connected, trying to connect..."
          
          # Connect to the device
          bluetoothctl connect ${macAddressProController}

          # Sleep 5 to wait for connection
          sleep 5
          
          # Check if the connection was successful
          connected=$(bluetoothctl info ${macAddressProController} | grep "Connected: yes")
      done

      echo "Device connected successfully"
    '';
  };

}