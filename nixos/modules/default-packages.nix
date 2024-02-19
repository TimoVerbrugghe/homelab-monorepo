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
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Setup git
  programs.git = {
    enable = true;
    config = {
        user.name = "${config.vars.gitUserName}";
        user.email = "${config.vars.gitUserEmail}";
    };
  };


}