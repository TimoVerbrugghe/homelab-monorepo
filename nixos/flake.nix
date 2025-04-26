{
  description = "Flake for Timo's homelab & personal machines";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    
    nixpkgs-unstable = { 
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    ssh-keys = {
      url = "https://github.com/TimoVerbrugghe.keys";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    # Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };


  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, home-manager-unstable, nixos-hardware, ssh-keys, nixos-generators, nix-darwin, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... } @inputs : {
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

      # Build this iso image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixosConfigurations.iso-generic-autoinstall.config.system.build.isoImage --no-write-lock-file --refresh
      iso-generic-autoinstall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          # Basic installer & install configuration
          ./isos/iso-generic-autoinstall/installer-configuration.nix
        ];
      };

      # Build this iso image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixosConfigurations.iso-flake-autoinstall.config.system.build.isoImage --no-write-lock-file --refresh
      # Don't forget to change the name of the flake you want to autoinstall first in the installer-configuration.nix
      iso-flake-autoinstall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./isos/iso-flake-autoinstall/installer-configuration.nix
        ];
      };

      # Build this iso image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixosConfigurations.gamingserver-iso-autoinstall.config.system.build.isoImage --no-write-lock-file --refresh
      gamingserver-iso-autoinstall = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          # Basic installer & install configuration
          ./isos/gamingserver-iso-autoinstall/installer-configuration.nix
        ];
      };

      # Build this iso image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#nixosConfigurations.surface-iso-install.config.system.build.isoImage --no-write-lock-file --refresh
      surface-iso-install = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          # Basic installer configuration
          ./isos/surface-iso-install/installer-configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-common
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#gamingserver --refresh --impure --no-write-lock-file
      gamingserver = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs // { pkgs-stable = inputs.nixpkgs.legacyPackages."x86_64-linux"; };
        modules = [
          ./machines/gamingserver/configuration.nix
          home-manager-unstable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.gamer = import ./machines/gamingserver/home.nix;
          }
        ];
      };

      # Switch to this config (for the next boot) with nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file
      surface = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./machines/surface/configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-common
          home-manager-unstable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.Timo = import ./machines/surface/home.nix;
          }
        ];
      };
    };

    packages.x86_64-linux = {
      # Build this Azure VHD image with nix build github:TimoVerbrugghe/homelab-monorepo?dir=nixos#azurenixos --no-write-lock-file --refresh
      azurenixos = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./machines/azurenixos/configuration.nix
          {
            # Pin nixpkgs to the flake input, so that the packages installed
            # come from the flake inputs.nixpkgs.url.
            nix.registry.nixpkgs.flake = nixpkgs;
            # set disk size to to 64G
            # virtualisation.diskSize = 64 * 1024;
          }
        ];
        format = "azure";
      };
    };

    darwinConfigurations = {
      # For a fresh install, first install nix-darwin by following instructions (including the flake init and installing a simple flake first) at https://github.com/LnL7/nix-darwin
      # Switch to this config with darwin-rebuild switch --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#TimosMacbookAir --impure --no-write-lock-file
      Timos-Macbook-Air = nix-darwin.lib.darwinSystem {
        specialArgs = inputs;
        modules = [
          # Fixes some issues with programs installed by nix (searching in spotlight, adding to dock) - see https://github.com/hraban/mac-app-util
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          ./machines/macbookair/configuration.nix
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "timo";

              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
        ];
      };
    };
  
  };
}