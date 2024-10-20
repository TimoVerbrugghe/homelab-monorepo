{ config, pkgs, ... }:

let
  surfaceGpePkg = pkgs.callPackage ./surface_gpe_localbuild.nix {};
in
{
  environment.systemPackages = with pkgs; [
    surfaceGpePkg
  ];

  boot.kernelModules = [
    "surface_gpe"
  ];
}
