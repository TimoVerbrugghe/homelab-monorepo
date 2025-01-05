{ config, lib, pkgs, ... }:

let
  # Get the hostname of the NixOS system
  hostname = config.networking.hostName;

in {

  imports =[ 
      # Include cloudflare API key file, you need to put this manually in your nixos install
      /etc/nixos/slack-webhook-url-2.nix
  ];

  # Define the systemd service
  systemd.services.disk-usage-monitor = {
    description = "Monitor disk usage and send Slack notifications";
    path = with pkgs; [
      curl
    ];
    script = ''
      disk_usage=$(df -h / | sed -n '2s/.* \([0-9]*\)%/\1/p' | tr -d '/')
      echo "Disk usage is $disk_usage"
      if [ "$disk_usage" -gt 80 ]; then
          echo "Disk Usage above 80%, sending Slack message"

          # Send Slack notification using curl
          curl -X POST -H 'Content-type: application/json' --data '{"text":"Disk Usage above 80% on ${hostname}"}' "${config.slackWebhookUrl}"

      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Define the systemd timer (once a day)
  systemd.timers.disk-usage-monitor = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";  # Run once a day
      Unit = "disk-usage-monitor.service";
    }; 
  };
}
