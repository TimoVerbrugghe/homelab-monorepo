{ config, pkgs, ... }:

{
  services.tailscale.enable = true;
  services.tailscale.extraUpFlags = [
    "--ssh"
  ];

  systemd.services.tailscale-cert-renewal = {
    enable = true;
    description = "Renew Tailscale certificates weekly";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.tailscale}/bin/tailscale cert ${config.vars.tailscaleDomain}";
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