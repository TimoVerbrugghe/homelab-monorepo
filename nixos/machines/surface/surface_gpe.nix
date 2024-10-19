{ stdenv, lib, fetchFromGitHub, pkgs, kmod }:

let 
  modDirVersion = "6.10.5";

  # Since my surface linux kernel is a specific version (at this point 6.10.5), I need to override the kernel version to match the one I have

  kernel = pkgs.linux_6_10.override {
	  argsOverride = rec {
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
        sha256 = "02yckkh6sxvcrwzbqgmw4jhqhxmbvz87xn9wm6bwwka3w2r9x41h";
      };
    version = "6.10.5";
    modDirVersion = "6.10.5";
    };
  };

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

  # For kernel modules it is necessary to disable pic in compiler hardenings as the kernel need different compiler flags.
  hardeningDisable = [ "pic" "format" ];

  #  In addition to other dependencies in nativeBuildInputs you should include kernel.moduleBuildDependencies as this propagates additional libraries required during the build.                                    
  nativeBuildInputs = kernel.moduleBuildDependencies;                       # 2

  # GitHub source has the module in a subfolder called module
  preBuild = ''
    cd module
  '';

  makeFlags = [
    # Best to define version manually instead of make trying to guess the module
    "KERNELRELEASE=${modDirVersion}"

    # Point make to build kernel tree
    "KERNEL_DIR=${kernel.dev}/lib/modules/${modDirVersion}/build"

    # it is required to give the kernel build system the right location where to install the kernel module
    "INSTALL_MOD_PATH=$(out)"
  ];

  meta = {
    description = "A custom version of the surface-gpe kernel module for Surface Laptop 5";
    homepage = "https://github.com/linux-surface/surface-gpe/tree/devices/sl5";
    platforms = lib.platforms.linux;
  };
}