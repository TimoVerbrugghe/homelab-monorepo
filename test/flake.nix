{
  description = "Flake for Timo's homelab & personal machines";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    
    ssh-keys = {
      url = "https://github.com/TimoVerbrugghe.keys";
      flake = false;
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

  outputs = { self, nixpkgs, ssh-keys, nix-darwin, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... } @inputs : {

    darwinConfigurations = {
      # For a fresh install, first install determinate nix using their MacOS package & install homebrew
      # Then switch to this config with sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake 'github:TimoVerbrugghe/homelab-monorepo?dir=nixos#Timos-Macbook-Air' --impure --no-write-lock-file
      ## WARNING: This will setup some "sh" login Items (System Settings -> Users & Groups -> Login Items) that will run nix commands on login, which set up the nix environment at boot. DO NOT TURN THESE OFF (otherwise /run/current-system will not be created and none of the nix packages will work).
      Timos-Macbook-Air = nix-darwin.lib.darwinSystem {
        specialArgs = inputs;
        modules = [
          # Fixes some issues with programs installed by nix (searching in spotlight, adding to dock) - see https://github.com/hraban/mac-app-util
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          ./macbookair/configuration.nix
          {
            # Disable nix-darwin managing nix since nix itself will be managed using determinate systems' installer - see https://docs.determinate.systems/guides/nix-darwin
            nix.enable = false;

            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Do not install homebrew as well under /usr/local (normally for compatability for intel software on ARM macs)
              enableRosetta = false;

              # User owning the Homebrew prefix
              user = "timo";

              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              # Optional: Enable fully-declarative tap management
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;

            };
          }
        ];
      };
    };
  
  };
}
