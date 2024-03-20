{ lib, ... }:

with lib;

{
  options = {
    cloudflareApiKey = mkOption {
      type = types.str;
      default = "";
      description = "Cloudflare API key";
    };
  };

  config = {
    cloudflareApiKey = ""; # Place cloudflare API key here
  };
}