{ config, pkgs, ... }:

{
  # Uinput has to be loaded as a kernel module in order for sunshine to emulate controller
  boot.kernelModules = [
    "uinput"
  ];

  environment.systemPackages = with pkgs; [
    sunshine
  ];

  # In wayland, sunshine needs additional security capabilities to detect displays
  security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
  };


  # Because of the additional security capabilities, path of sunshine in systemd service has to be changed
  systemd.user.services.sunshine =
    {
      description = "sunshine";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${config.security.wrapperDir}/sunshine";
      };
    };

  # Needed for autodetection of sunshine in moonlight
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
    ];
  };

}