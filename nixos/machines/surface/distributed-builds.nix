{ pkgs, ... }:
{
  nix.distributedBuilds = true;
  nix.settings.max-jobs = 0; # Only use remote builders, do not build locally

	nix.extraOptions = ''
	  builders-use-substitutes = true
	'';

  nix.buildMachines = [
    {
      hostName = "odd.local.timo.be";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
    {
      hostName = "ulrich.local.timo.be";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
    {
      hostName = "yumi.local.timo.be";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      system = pkgs.stdenv.hostPlatform.system;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
  ];
}