{ qt6Packages
, fetchFromGitHub
, fetchurl
, ...
}:

let
  source = /etc/nixos/citra-unified-source.tar.xz;
in {
  nightly = qt6Packages.callPackage ./package.nix rec {
    pname = "citra-nightly";
    version = "2088";

    src = source;
  };
}