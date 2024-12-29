{ config, pkgs, ... }:

{
  # Enable Docker & Install docker compose
	virtualisation.docker = {
		enable = true;
		autoPrune.enable = true;
	  autoPrune.dates = "weekly";
	  enableOnBoot = true;
	  liveRestore = false; # will affect running containers when restarting docker daemon, but resolves stuck shutdown/reboot

	  # Disable the docker-proxy userland proxy and instead use iptables for all docker routing. Disabled because having issues with docker-proxy holding on to ports across reboots, which causes container startup to fail.
	  extraOptions = "--userland-proxy=false --log-opt gelf-address=udp://10.10.10.2:1515";

		logDriver = "gelf";
	};

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