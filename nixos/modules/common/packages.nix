{ config, pkgs, ... }:

{
  ### Install packages ###
  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    pciutils
    jq
    iputils
    fastfetch
    tmux
    nfs-utils
  ];

}