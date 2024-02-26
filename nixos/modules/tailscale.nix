{ config, pkgs, ... }:

with lib;
with types;

let
  cfg = config.services.tailscale;
in

{

  options.services.tailscale = {
    hostname = mkOption {
      type = types.str;
    };
  };

  imports =
    [ # Include tailscale authkey file, you need to put this manually in your nixos install
      /etc/nixos/tailscale-authkey.nix
    ];

  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--ssh"
  ];

  # Tailscale Authkey
  services.tailscale.authKeyFile = pkgs.writeText "tailscale_authkey" ''
    ${config.tailscaleAuthKey}
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

}