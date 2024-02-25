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

  outputs = { self, nixpkgs, ... } @inputs : {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/nixos/configuration.nix
        ];
      };
      iso-autoinstall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          # Basic installer & install configuration
          ./iso-autoinstall/installer-configuration.nix
        ];
      };
    };
  };
}