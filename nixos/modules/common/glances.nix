{ config, pkgs, ... }:

{
  services.glances = {
    enable = true;
    openFirewall = true;
    extraArgs = [
      "--webserver"
      "--disable-webui"
      "--quiet"
    ];
  };
}