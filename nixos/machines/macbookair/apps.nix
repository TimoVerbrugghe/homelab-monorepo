{ config, pkgs, ... }:

let 

  username = "timo";

in

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  # WARNING: Less stable on MacOS than homebrew
  environment.systemPackages = with pkgs; [ 
    vim
    fastfetch
    git
    ansible
    sshpass
    python313Packages.dnspython
    talosctl
    minikube
  ];
  
  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  programs.tmux.enable = true;

  homebrew = {
    enable = true;

    # Install mas cli to get Mac App Store IDs for masApps
    brews = [
      "mas"
      "kubernetes-cli"
      "nano"
    ];
    casks = [
      "tailscale"
    ];
    masApps = {};

    # Remove any casks that are not defined in this nix config
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  }

}