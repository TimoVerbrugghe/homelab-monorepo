{ config, pkgs, ... }:

let 
  portainerCompose = pkgs.writeText "portainer-docker-compose.yml" ''
    version: '3.8'

    services:
      portainer-agent:
        container_name: portainer-agent
        image: portainer/agent:latest
        restart: always
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - /var/lib/docker/volumes:/var/lib/docker/volumes
        ports:
          - "9001:9001"
  '';

in

{
  ## Enable Portainer at startup
  systemd.services.portainer = {
    enable = true;
    description = "Portainer";
    after = [ "network-online.target" "docker.service" "docker.socket"];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${portainerCompose} up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${portainerCompose} down";
      Restart = "always";
      RestartSec = "30s";
    };
  };
}