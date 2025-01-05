{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  acmeEmail = "timo@hotmail.be";

  # Path to cloudflare key
  secretFilePath = "/etc/nixos/cloudflare-key";

  # Check if cloudflare key file exists
  secretFileExists = builtins.pathExists secretFilePath;

  # Conditionally read cloudflare key
  cloudflareApiKey = if secretFileExists
                    then builtins.readFile secretFilePath
                    else null;

in

{

  # Certificates generated will be stored in /var/lib/acme
  security.acme = lib.mkIf secretFileExists {
    acceptTerms = true;
    defaults.email = acmeEmail;
    defaults.environmentFile = "${pkgs.writeText "cloudflare-env" ''
      CLOUDFLARE_DNS_API_TOKEN=${cloudflareApiKey}
    ''}";
    defaults.dnsProvider = "cloudflare";
    defaults.dnsResolver = "1.1.1.1:53";

    certs = {
      "timo.be" = {
        extraDomainNames = [ "*.local.timo.be" "dns.timo.be" "local.timo.be" "home.timo.be" "*.home.timo.be" ];
      };
    };
  };

}

