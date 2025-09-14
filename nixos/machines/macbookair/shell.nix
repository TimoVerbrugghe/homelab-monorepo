{ config, lib, pkgs, ... }:

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
    talosctl
    minikube
		cmatrix
    fzf
    zoxide
    eza
    nmap
    jq
  ];

  homebrew = {
    brews = [
      "bat"
    ];
  };

	# Shell aliases
  environment.shellAliases = {
    k = "kubectl";
    t = "talosctl --talosconfig talosconfig -e 10.10.10.33";
    fzf = "fzf --preview 'bat --color=always {}'";
    z = "zoxide";
    ls = "eza --group-directories-first";
    
    # Collecting nix garbage both before and after to rebuild to avoid MDM errors that get triggered due to duplicate installations of applications
    nixupdate = "sudo nix-collect-garbage -d && sudo darwin-rebuild switch --flake 'github:TimoVerbrugghe/homelab-monorepo?dir=nixos#Timos-Macbook-Air' --refresh --impure --no-write-lock-file && sudo nix-collect-garbage -d";
  };
 }