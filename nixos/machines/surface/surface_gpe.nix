{ stdenv, lib, fetchFromGitHub, pkgs, kmod }:

let 
  modDirVersion = "6.10.5";

  kernel = pkgs.linuxPackagesFor (pkgs.linux_6_10.override {
	argsOverride = rec {
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v6.x/linux-${modDirVersion}.tar.xz";
        sha256 = null;
      };
    version = "6.10.5";
    modDirVersion = "6.10.5";
    };
  });

in

stdenv.mkDerivation rec {
  pname = "surface-gpe_sl5";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "linux-surface";
    repo = "surface-gpe";
    rev = "071ee4517b3397172a28a291751d84dcad584f00"; # Pointing to the specific commit for support for Surface Laptop 5, still in separate branch (https://github.com/linux-surface/surface-gpe/tree/devices/sl5)
    hash = "sha256-jejsoEXclQqmChlj8Gbw9jX3noT/xUqkyy5SZ1f8aBw=";
  };

  hardeningDisable = [ "pic" "format" ];                                             # 1
  nativeBuildInputs = kernel.moduleBuildDependencies;                       # 2

  preBuild = ''
    cd module
  '';

  makeFlags = [
    "KERNELRELEASE=${modDirVersion}"                                 # 3
    "KERNEL_DIR=${kernel.dev}/lib/modules/${modDirVersion}/build"    # 4
    "INSTALL_MOD_PATH=$(out)"                                               # 5
  ];

  meta = {
    description = "A custom version of the surface-gpe kernel module for Surface Laptop 5";
    homepage = "https://github.com/linux-surface/surface-gpe/tree/devices/sl5";
    platforms = lib.platforms.linux;
  };
}