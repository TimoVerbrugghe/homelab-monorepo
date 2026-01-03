# Glib Schemas Fix
# https://github.com/thomX75/nixos-modules

{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [ gtk3 ];

  environment.variables = rec {
    GSETTINGS_SCHEMA_DIR="${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  }; 

}