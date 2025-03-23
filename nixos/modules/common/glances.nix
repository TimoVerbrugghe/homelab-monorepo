{ config, pkgs, ... }:

{
  services.glances = {
    enable = true;
    openFirewall = true;
    extraArgs = "--disable-webui --server --quiet";
  };
}