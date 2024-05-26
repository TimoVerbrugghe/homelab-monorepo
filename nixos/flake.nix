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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, ... } @inputs : {
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

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#francis --refresh --impure --no-write-lock-file
      francis = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/francis/configuration.nix
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#david --refresh --impure --no-write-lock-file
      david = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/david/configuration.nix
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

      # Build this iso image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixosConfigurations.gamingserver-iso-autoinstall.config.system.build.isoImage --no-write-lock-file --refresh
      gamingserver-iso-autoinstall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          # Basic installer & install configuration
          ./gamingserver-iso-autoinstall/installer-configuration.nix
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#gamingserver --refresh --impure --no-write-lock-file
      gamingserver = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/gamingserver/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.gamer = import ./machines/gamingserver/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#k3stest --refresh --impure --no-write-lock-file
      k3stest = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/k3stest/configuration.nix
        ];
      };

    };
  };
}