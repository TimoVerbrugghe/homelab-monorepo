{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
  ];

  hardware = {
    sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices = {
          home = { model = "DCP-L2627DWE"; ip = "10.10.10.197"; };
        };
      };
    };
  };
}