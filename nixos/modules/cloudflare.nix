{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  acmeEmail = "timo@hotmail.be";
in

{

  imports =[ 
      # Include cloudflare API key file, you need to put this manually in your nixos install
      /etc/nixos/cloudflare-keys.nix
  ];


  # Certificates generated will be stored in /var/lib/acme
  security.acme = {
    acceptTerms = true;
    defaults.email = acmeEmail;
    defaults.environmentFile = "${pkgs.writeText "cloudflare-env" ''
      CLOUDFLARE_DNS_API_TOKEN=${config.cloudflareApiKey}
    ''}";
    defaults.dnsProvider = "cloudflare";
    defaults.dnsResolver = "1.1.1.1:53";

    certs = {
      "timo.be" = {
        extraDomainNames = [ "*.home.timo.be" "dns.timo.be" "home.timo.be" ];
      };
    };
  };

  services.cloudflared.enable = true;

  systemd.services.cloudflareTunnel = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${config.cloudflareTunnelToken}";
        Restart = "always";
        User = "cloudflared";
        Group = "cloudflared";
    };
  };

}

