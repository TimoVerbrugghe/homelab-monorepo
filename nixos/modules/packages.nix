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
    neofetch
    tmux
    nfs-utils
  ];

}