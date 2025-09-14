{ config, pkgs, ... }:

{
  # Adding default DNS servers
  networking.nameservers = [
    "10.10.10.35"
    "10.10.10.21"
    "10.10.10.22"
  ];

  # Add a dns manager so that tailscale does not overwrite /etc/resolv.conf. Ensures that docker dns keeps working
  services.resolved = {
    enable = true;
    domains = [ "~." ];
    fallbackDns = [ "10.10.10.35" "10.10.10.21" "10.10.10.22" ];
  };
}