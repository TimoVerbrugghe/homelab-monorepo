{ config, pkgs, ... }:

{
  ## Shell tools, mostly coming from https://www.youtube.com/watch?v=79rmEOrd5u8
  environment.systemPackages = with pkgs; [
    cmatrix
    fzf
    fastfetch
    zoxide
    eza
    nmap
    jq
  ];

  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    fuzzyCompletion = true;
  };

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  # Shell aliases
  environment.shellAliases = {
    k = "kubectl";
    t = "talosctl";
    fzf = "fzf --preview 'bat --color=always {}'";
    z = "zoxide";
    ls = "eza --group-directories-first";
    cd = "zoxide";
  };

  # Fastfetch
  environment.etc."fastfetch.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "display",
        "de",
        "wm",
        "wmtheme",
        "cpu",
        "gpu",
        "memory",
        "disk",
        "localip",
        "battery",
        "poweradapter"
      ]
    }
  '';

  programs.bash = {
    loginShellInit = ''
      # Check if the shell is a login shell
      if [ -n "$BASH_VERSION" ] && [ -z "$SSH_TTY" ]; then
        fastfetch -c /etc/fastfetch.jsonc
      fi
    '';
  };
}