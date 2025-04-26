{ config, inputs, lib, pkgs, ssh-keys, self, ... }:

let

  username = "timo";
  hostname = "Timos-Macbook-Air";

in

{
  imports =
    [ 
      ./apps.nix
      ./system-settings.nix
			./shell.nix    
    ];

  networking.hostName = "${hostname}";
  networking.computerName = "${hostname}";
  system.defaults.smb.NetBIOSName = "${hostname}";

  users.users."${username}" = {
    home = "/Users/${username}";
    description = "${username}";
  };

	# Nix-store optimizations
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

	# Add github key to avoid auth errors when doing multiple darwin-rebuilds in quick succession
	nix.extraOptions = ''
    !include /etc/nix/github.key
  '';

  nix.settings.trusted-users = [ "${username}" ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Increase the download buffer size to 500M to avoid timeouts when downloading large files.
  nix.settings.download-buffer-size = 524288000;

  # Let nix-darwin manage the nix installation, nix-daemon & nix settings
  nix.enable = true;
  nix.package = pkgs.nix;

  # Allow installation of unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.activationScripts = {
    postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };
}