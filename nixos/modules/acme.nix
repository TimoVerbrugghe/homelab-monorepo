{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  acmeEmail = "timo@hotmail.be";
in

{

  imports =[ 
      # Include cloudflare API key file, you need to put this manually in your nixos install
      /etc/nixos/cloudflare-apikey.nix
  ];

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


}

