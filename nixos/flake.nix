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

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#aelita --refresh --impure --no-write-lock-file
      aelita = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/aelita/configuration.nix
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#odd --refresh --impure --no-write-lock-file
      odd = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/odd/configuration.nix
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#ulrich --refresh --impure --no-write-lock-file
      ulrich = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/ulrich/configuration.nix
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#yumi --refresh --impure --no-write-lock-file
      yumi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/yumi/configuration.nix
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixos --refresh --impure --no-write-lock-file
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/nixos/configuration.nix
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#francis --refresh --impure --no-write-lock-file
      francis = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/francis/configuration.nix
        ];
      };


      # Build this iso image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixosConfigurations.iso-autoinstall.config.system.build.isoImage --no-write-lock-file --refresh
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