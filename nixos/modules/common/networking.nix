{ config, pkgs, ... }:

{
  # Increase UDP Buffer size to 25 MB
  boot.kernel.sysctl = { 
    "net.core.rmem_max" = 25000000; 
    "net.core.wmem_max" = 25000000; 
    "net.core.rmem_default" = 25000000;
    "net.core.wmem_default" = 25000000;
  };

}