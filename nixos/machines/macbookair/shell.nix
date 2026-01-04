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
    tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    
    # Collecting nix garbage both before and after to rebuild to avoid MDM errors that get triggered due to duplicate installations of applications
    # Darwin system rebuild command that:
    # 1. Updates nix using determinate-nixd to the latest version
    # 2. Collects garbage and removes old generations before the rebuild
    # 3. Rebuilds the system using the flake from the GitHub repository
    #    - Uses the 'Timos-Macbook-Air' configuration from the nixos directory
    #    - Refreshes flake inputs to get latest versions
    #    - Uses impure evaluation to allow environment variables and system state
    #    - Prevents writing changes to the flake.lock file
    # 4. Collects garbage again after rebuild to clean up build artifacts
    nixupdate = "sudo determinate-nixd upgrade && sudo nix-collect-garbage -d && sudo darwin-rebuild switch --flake 'github:TimoVerbrugghe/homelab-monorepo?dir=nixos#Timos-Macbook-Air' --refresh --impure --no-write-lock-file && sudo nix-collect-garbage -d";
  };
 }