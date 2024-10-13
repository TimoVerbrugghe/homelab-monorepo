{
  description = "flake for nixos";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
    };

    ssh-keys = {
      url = "https://github.com/TimoVerbrugghe.keys";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, lanzaboote, ... } @inputs : {
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

      # Build this iso image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixosConfigurations.surface-iso-install.config.system.build.isoImage --no-write-lock-file --refresh
      surface-iso-install = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          # Basic installer configuration
          ./surface-iso-install/installer-configuration.nix

          nixos-hardware.nixosModules.microsoft-surface-common
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

          }
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file
      surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/surface/configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-common
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.timo = import ./machines/surface/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
          lanzaboote.nixosModules.lanzaboote
        ];
      };

    };
  };
}