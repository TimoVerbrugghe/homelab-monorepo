{ config, pkgs, ... }:

{
  # Increase UDP Buffer size to 25 MB
  boot.kernel.sysctl = { 
    "net.core.rmem_max" = 25000000; 
    "net.core.wmem_max" = 25000000; 
    "net.core.rmem_default" = 25000000;
    "net.core.wmem_default" = 25000000;
  };

  # Disable ipv6 forwarding for better compatibility with matter server (see https://github.com/home-assistant-libs/python-matter-server/blob/main/README.md#requirements-to-communicate-with-thread-devices-through-thread-border-routers)

  boot.kernel.sysctl = {
    # Disabling ipv6 forwarding
    "net.ipv6.conf.all.forwarding" = 0;

    "net.ipv6.conf.eth0.accept_ra" = 1;
    "net.ipv6.conf.eth0.accept_ra_rt_info_max_plen" = 64;
    "net.ipv6.conf.macvlan0.accept_ra" = 1;
    "net.ipv6.conf.macvlan0.accept_ra_rt_info_max_plen" = 64;
  }

}