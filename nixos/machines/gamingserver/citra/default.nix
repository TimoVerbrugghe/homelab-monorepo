{ qt6Packages
, fetchFromGitHub
, fetchurl
}:

let
  source = /etc/nixos/citra-unified-source.tar;
in {
  nightly = qt6Packages.callPackage ./generic.nix rec {
    pname = "citra-nightly";
    version = "2088";

    src = source;
  };
}