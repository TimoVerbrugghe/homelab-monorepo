{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  cfg = config.services.tailscale;

  # Path to tailscale authkey
  secretFilePath = "/etc/nixos/tailscale-authkey";

  # Check if tailscale authkey file exists
  secretFileExists = builtins.pathExists secretFilePath;

  # Conditionally read tailscale authkey
  tailscaleAuthKey = if secretFileExists
                    then builtins.readFile secretFilePath
                    else null;
in

{

  options.services.tailscale = {
    hostname = mkOption {
      type = types.str;
    };
  };

  # Only configure tailscale if tailscale-authkey exists
  config = lib.mkIf secretFileExists {
    services.tailscale.enable = true;
    services.tailscale.extraUpFlags = [
      "--ssh"
    ];

    # Tailscale Authkey
    services.tailscale.authKeyFile = pkgs.writeText "tailscale_authkey" ''
      ${tailscaleAuthKey}
    '';

    systemd.services.tailscale-cert-renewal = {
      enable = true;
      description = "Renew Tailscale certificates weekly";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.tailscale}/bin/tailscale cert ${cfg.hostname}.${config.vars.tailscaleDomain}";
      };
      wantedBy = [ "multi-user.target" ];
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };

    # Renew tailscale certs on weekly basis and on startup
    systemd.timers.tailscale-cert-renewal = {
      description = "Run Tailscale certificate renewal weekly";
      timerConfig = {
        OnCalendar = "weekly";
        Unit = "tailscale-cert-renewal.service";
      };
    };

  };

}