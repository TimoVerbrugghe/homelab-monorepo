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
        specialArgs = {inherit inputs;};
        modules = [
          # Import minimal ISO CD
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

          # Import tools (needed for certain options such as system.nixos-generate-config)
          "${nixpkgs}/nixos/modules/installer/tools/tools.nix"

          # Provide an initial copy of the NixOS channel so that the user
          # doesn't need to run "nix-channel --update" first.
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

          # Basic installer & install configuration
          ./iso-autoinstall/installer-configuration.nix
        ];
      };
    };
  };
}