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
    t = "talosctl --talosconfig talosconfig -n william.local.timo.be -e william.local.timo.be";
    fzf = "fzf --preview 'bat --color=always {}'";
    z = "zoxide";
    ls = "eza --group-directories-first";
    nixupdate = "sudo nix-collect-garbage -d && sudo darwin-rebuild switch --flake 'github:TimoVerbrugghe/homelab-monorepo?dir=nixos#Timos-Macbook-Air' --refresh --impure --no-write-lock-file";
  };
 }