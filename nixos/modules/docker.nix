{ config, pkgs, ... }:

{
  # Enable Docker & Install docker compose
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates = "weekly";
  virtualisation.docker.enableOnBoot = true;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}