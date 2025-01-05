{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  acmeEmail = "timo@hotmail.be";

  # Path to cloudflare key
  secretFilePath = "/etc/nixos/cloudflare-tunnel-token";

  # Check if cloudflare key file exists
  secretFileExists = builtins.pathExists secretFilePath;

  # Conditionally read cloudflare key
  cloudflareTunnelToken = if secretFileExists
                          then builtins.readFile secretFilePath
                          else null;

in

{
  
  services.cloudflared.enable = true;

  systemd.services.cloudflareTunnel = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${cloudflareTunnelToken}";
        Restart = "always";
        User = "cloudflared";
        Group = "cloudflared";
    };
  };

}

