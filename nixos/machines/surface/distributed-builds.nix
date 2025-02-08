{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  nix.settings.max-jobs = 0; # Only use remote builders, do not build locally

	nix.extraOptions = ''
	  builders-use-substitutes = true
	'';

  nix.buildMachines = [
    {
      hostName = "gamingserver.local.timo.be";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
    {
      hostName = "azurenixbuilder.azure.timo.be";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
    
  ];
}