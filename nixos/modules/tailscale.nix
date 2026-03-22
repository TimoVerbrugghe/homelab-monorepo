{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  cfg = config.services.tailscale;

  # Path to tailscale oauth secret
  secretFilePath = "/etc/nixos/tailscale-oauth-secret";

  # Check if tailscale oauth secret file exists
  secretFileExists = builtins.pathExists secretFilePath;

  # Conditionally read tailscale oauth secret
  tailscaleOauthSecret = if secretFileExists
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
    services.tailscale = {
      enable = true;
      authKeyFile = pkgs.writeText "tailscale_oauth_secret" ''
        ${tailscaleOauthSecret}
      '';
      authKeyParameters = {
        ephemeral = false;
        preauthorized = true;
      };
      extraUpFlags = [
        "--ssh"
      ];
      useRoutingFeatures = "both";
    };

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

