{ config, pkgs, ... }:

{
  # Enable Docker & Install docker compose
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates = "weekly";
  virtualisation.docker.enableOnBoot = true;
	virtualisation.docker.liveRestore = false; # will affect running containers when restarting docker daemon, but resolves stuck shutdown/reboot

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}