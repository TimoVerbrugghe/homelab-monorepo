{ config, pkgs, ... }:

let 
  portainerCompose = pkgs.writeText "portainer-docker-compose.yaml" ''
    version: '3.8'

    name: portainer

    services:
      portainer:
        image: portainer/portainer-ce:sts
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
          traefik.http.routers.portainer.entrypoints: https
          traefik.http.services.portainer.loadbalancer.server.port: 9443
          traefik.http.services.portainer.loadbalancer.server.scheme: https
          traefik.http.routers.portainer.rule: Host(`portainer.home.timo.be`) || Host(`portainer.timo.be`)
          tsdproxy.enable: true
          tsdproxy.container_port: 9443
          tsdproxy.name: "portainer"
          tsdproxy.ephemeral: false

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