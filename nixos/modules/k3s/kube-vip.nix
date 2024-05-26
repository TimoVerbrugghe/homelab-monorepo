{ config, pkgs, ... }:

{
  # Install kube-vip
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./kube-vip-package.nix {})
  ];
}
