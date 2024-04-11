{ config, pkgs, ... }:

{

  ## TO-DO: Automatic configuration of plasma theme management
    # Create .local/share/plasma/desktoptheme/Vapor with wallpaper and settings
    # Create .local/share/plasma/look-and-feel/Vapor with correct layout settings
    # Create a systemd service that executes plasma-apply-lookandfeel -a Vapor --resetLayout to apply the theme and all of its look-and-feel settings

  environment.systemPackages = with pkgs; [

    # Current emulationstation-de is old (2.2.1), so temporarily building the package 3.0.1 myself using the commit https://github.com/NixOS/nixpkgs/pull/299298 until it's pulled
    (pkgs.callPackage ./vapor-nixos-theme/default.nix {})
  ];

}