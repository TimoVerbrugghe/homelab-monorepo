{ lib
, pkgs
, ... }:

let

  package = pkgs.gnome.gvfs;

in {

  security.wrappers.gvfsd-nfs = {
    source  = "${package}/libexec/gvfsd-nfs";
    owner   = "nobody";
    group   = "nogroup";
    capabilities = "cap_net_bind_service+ep";
  };

  services.gvfs = {
    enable = true;
    package = lib.mkForce (package.overrideAttrs (oldAttrs: {
      postInstall = ''
        ln -sf /run/wrappers/bin/gvfsd-nfs $out/libexec/gvfsd-nfs
      '';
    }));
  };

}