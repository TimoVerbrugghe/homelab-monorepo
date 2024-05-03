{ config, pkgs, ... }:

let 
  portainerCompose = pkgs.writeText "portainer-docker-compose.yml" ''
    version: '3.8'

    name: portainer

    services:
      portainer:
        image: portainer/portainer-ce:latest
        container_name: portainer
        restart: always
        networks:
          - dockerproxy
        hostname: portainer
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - portainer:/data
        ports:
          - "8000:8000"
          - "9443:9443"
        labels:
          traefik.enable: false
    
    volumes:
      portainer:

    networks:
      dockerproxy:
        name: dockerproxy
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
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${portainerCompose} -p portainer up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${portainerCompose} -p portainer down";
      Restart = "always";
      RestartSec = "30s";
    };
  };
}