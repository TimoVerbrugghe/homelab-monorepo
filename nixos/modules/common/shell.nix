{ config, pkgs, ... }:

{
  ## Shell tools, mostly coming from https://www.youtube.com/watch?v=79rmEOrd5u8
  environment.systemPackages = with pkgs; [
    cmatrix
    fzf
    fastfetch
  ];

  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    fuzzyCompletion = true;
  };

  # Shell aliases
  environment.shellAliases = {
    k = "kubectl";
    t = "talosctl";
    fzf = "fzf --preview 'bat --color=always {}'";
    nixupdatelocalboot = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --builders ''";
    nixupdatelocalswitch = "nixos-rebuild switch --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --builders ''";
  };

  programs.bash = {
    loginShellInit = '' 
      # Check if the shell is a login shell 
      if [ -n "$BASH_VERSION" ] && [ -z "$SSH_TTY" ]; then
        fastfetch -c /home/Timo/.config/fastfetch/config.jsonc  
      fi 
    '';
  };
}