{
  description = "flake for nixos";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    ssh-keys = {
      url = "https://github.com/TimoVerbrugghe.keys";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@attrs : {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit attrs;
          username = "nixos";
          hostname = "nixos";
        };
        modules = [
          ./machines/nixos/configuration.nix
        ];
      };
    };
  };
}