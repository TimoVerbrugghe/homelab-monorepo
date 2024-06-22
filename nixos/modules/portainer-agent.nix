{ config, pkgs, ... }:

let 
  portainerCompose = pkgs.writeText "portainer-docker-compose.yml" ''
    version: '3.8'

    name: portainer

    services:
      portainer-agent:
        container_name: portainer-agent
        image: portainer/agent:sts
        restart: always
        networks:
          - dockerproxy
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - /var/lib/docker/volumes:/var/lib/docker/volumes
        ports:
          - "9001:9001"
      
    networks:
      dockerproxy
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
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${portainerCompose} down";
      Restart = "always";
      RestartSec = "30s";
    };
  };
}