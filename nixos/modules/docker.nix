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

  ## Add this systemd service because docker keeps quitting containers on startup that I have connected with tailscale even with docker compose healthchecks -_-'

  systemd.services.docker-container-restart = {
    description = "Periodically restart Docker containers with specific error - cannot join network of running container";
    after = [ "network-online.target" "docker.service" "docker.socket"];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    enable = true;
    path = with pkgs; [
      docker
    ];
    script = ''
      docker ps -a --filter "status=exited" --format "{{.ID}}" | while read -r container_id; do
        error=$(docker inspect --format "{{.State.Error}}" "$container_id")
        if [[ "$error" == *"cannot join network of a non running container"* ]]; then
          docker restart "$container_id"
        fi
      done
    '';
    serviceConfig = {
      User = "root";
      Group = "root";
      Type = "oneshot";
      restart = "no";
    };
    
  };

  systemd.timers.docker-container-restart = {
    description = "Timer to periodically restart Docker containers";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/3";  # Run every 3 minutes
      Persistent = true;
    };
  };
}