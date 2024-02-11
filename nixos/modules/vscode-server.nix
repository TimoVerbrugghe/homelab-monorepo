{ config, pkgs, ... }:

{
  # Necessary to install vscode.fhs
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vscode.fhs
  ];

  # Enable fix so that VS Code remote works
  programs.nix-ld.enable = true;

  # Enable network-online.target
  systemd.services.NetworkManager-wait-online.enable = true;

  # Start vscode at startup
  systemd.services.code-tunnel = {
    enable = true;
    description = "Enable VS Code tunnel";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.vscode.fhs}/bin/code --user-data-dir='/root/.vscode/' tunnel --accept-server-license-terms --cli-data-dir /root/.vscode-cli";
    };
    wantedBy = [ "default.target" ];
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

}