# Set up possibility to use this machine as a remote builder.
# More info at https://nix.dev/tutorials/nixos/distributed-builds-setup.html#distributed-builds-config-nixos

{ config, pkgs, ssh-keys, ... }:

{
  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";
    openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
  };

  services.openssh = {
    settings = {
      AllowUsers = ["remotebuild"]; # Allows all users by default. Can be [ "user1" "user2" ]
    };
  };

  users.groups.remotebuild = {};

  nix = {
    nrBuildUsers = 64;
    settings = {
      trusted-users = [ "remotebuild" ];
    };
  };

  nix.extraOptions = ''
	  builders-use-substitutes = true
	'';
}