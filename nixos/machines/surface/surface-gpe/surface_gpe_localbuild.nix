# Installing custom surface_gpe.ko kernel module compiled from souce locally on already running nixos with linux-surface kernel
# Source: https://github.com/linux-surface/surface-gpe/tree/devices/sl5
# Clone this source using git clone to a folder (f.e. /root/surface-gpe)
# Compiled using make -C /nix/store/<path to current kernel -dev folder> (f.e. <guid>-linux-6.10.5-dev)/lib/modules/6.10.5/build M=/root/surface-gpe/module modules
# Copied compiled surface_gpe.ko to this folder

{ stdenv, lib }:

stdenv.mkDerivation {
  pname = "surface-gpe";
  version = "1.0-sl5";

  src = ./surface_gpe.ko;

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/lib/modules/$(uname -r)/kernel/drivers/platform/surface/
    cp $src $out/lib/modules/$(uname -r)/kernel/drivers/platform/surface/surface_gpe.ko
  '';

  meta = {
    description = "A custom version of the surface-gpe kernel module for Surface Laptop 5";
    homepage = "https://github.com/linux-surface/surface-gpe/tree/devices/sl5";
    platforms = lib.platforms.linux;
  };
}
