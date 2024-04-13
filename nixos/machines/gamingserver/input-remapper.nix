{ config, pkgs, ... }:

{
  # Enable input-remapper
  services.input-remapper.enable = true;

  ## Udev rule for when Xbox controller gets plugged in
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", ATTRS{name}=="Microsoft X-Box 360 pad", RUN+="${pkgs.systemd}/bin/systemctl restart input-remapper-autoload.service"
  '';

  # Create input-remapper-autoload service that gets triggered by the udev rule so that input-remapper rules get reloaded again when controller gets plugged in again (because they stop when controller disconnects)
  
  systemd.user.services.input-remapper-autoload = {
    enable = true;
    path = with pkgs; [
      input-remapper
    ];
    wantedBy = [ "graphical-session.target" ];
    after = [ "input-remapper.service" ];
    script = ''
      input-remapper-control --command stop-all
      input-remapper-control --command autoload
    '';
    serviceConfig = {
      Type="oneshot";
    };
  };
  
}