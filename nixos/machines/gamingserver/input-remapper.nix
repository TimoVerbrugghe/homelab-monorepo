{ config, pkgs, ... }:

{
  # Enable input-remapper
  services.input-remapper = {
    enable = true;

    ## Enable built-in udev rules for when Xbox Controller is plugged in/connected through sunshine
    enableUdevRules = true;
  };

  systemd.services.input-remapper = {
    path = with pkgs; [
      input-remapper
    ];
    wantedBy = [ "graphical.target" ];
    requires = ["dbus.service"];
    after = ["dbus.service"];
    serviceConfig = {
      Type="dbus";
      BusName="inputremapper.Control";
      ExecStart="";
      ExecStart="${pkgs.input-remapper}/bin/input-remapper-service -d";
    };
  };
}