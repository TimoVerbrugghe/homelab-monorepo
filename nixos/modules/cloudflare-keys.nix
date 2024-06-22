{ lib, ... }:

with lib;

{
  options = {
    cloudflareApiKey = mkOption {
      type = types.str;
      default = "";
      description = "Cloudflare API key";
    };

    cloudflareTunnelToken= mkOption {
      type = types.str;
      default = "";
      description = "Cloudflare Tunnel Token";
    };
  };

  config = {
    cloudflareApiKey = ""; # Place cloudflare API key here
    cloudflareTunnelToken = ""; # Place cloudflare tunnel token here
  };
}