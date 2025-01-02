{ config, pkgs, ... }:

{
  hardware = {
    sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices = {
          home = { model = "DCP-L2627DWE"; ip = "10.10.10.197"; };
        };
      };
    };
  };
}