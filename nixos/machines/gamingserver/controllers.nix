{ config, pkgs, ... }:

let
  macAddressProController = "28:CF:51:A5:86:6E";
in

{

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Enable support for joycons & Pro Controller
  services.joycond.enable = true;

  # AX200 Bluetooth module
  boot.kernelModules = [ "btintel" ];

  services.udev.extraRules = ''
    ACTION=="remove", SUBSYSTEM=="bluetooth", ATTR{address}=="${macAddressProController}", RUN+="${pkgs.systemd}/bin/systemctl start switch-procontroller-bluetooth-reconnect.service"
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
      ## NEED TO PUT || true in this script because nixos puts set -e in the script automatically which exits script on any non-zero exit code

      # Check if the device is already connected
      connected=$(bluetoothctl info ${macAddressProController} | grep "Connected: yes" || true)

      while [ -z "$connected" ]; do
          echo "Device is not connected, trying to connect..."
          
          # Connect to the device
          bluetoothctl connect ${macAddressProController} || true

          # Check if the connection was successful
          connected=$(bluetoothctl info ${macAddressProController} | grep "Connected: yes" || true)

          # Sleep for 5 seconds before trying again
          sleep 5
      done

      echo "Device connected successfully"
    '';
  };

}