{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  certbotCompose = pkgs.writeText "certbot-docker-compose.yml" ''
    version: '3.8'
    name: certbot
    services:
      name: certbot
      image: certbot/dns-cloudflare
      restart_policy: unless-stopped
      state: started
      volumes:
        - /etc/letsencrypt:/etc/letsencrypt
      dns_servers:
        - "8.8.8.8"
        - "1.1.1.1"
      command: |
        certonly 
        --non-interactive --keep-until-expiring --agree-tos --no-eff-email
        --dns-cloudflare
        -m timo@hotmail.be 
        --dns-cloudflare-propagation-seconds 20 
        --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini
        --cert-name timo.be 
        -d dns.timo.be
        -d home.timo.be
        -d *.home.timo.be
  '';

in

{

  imports =[ 
      # Include cloudflare API key file, you need to put this manually in your nixos install
      /etc/nixos/cloudflare-apikey.nix
  ];

    ## Write cloudflare api key to the right location (/etc/letsencrypt/cloudflare.ini)
    environment.etc."letsencrypt/cloudflare.ini".text = ''
      dns_cloudflare_api_token = "${config.cloudflareApiKey}";
    '';


    ## Enable Certbot at startup
    systemd.services.certbot = {
      enable = true;
      description = "Certbot";
      after = [ "network-online.target" "docker.service" "docker.socket"];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${certbotCompose} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${certbotCompose} down";
        Restart = "always";
        RestartSec = "30s";
      };
  };
}

