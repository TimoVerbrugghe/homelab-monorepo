{ config, lib, pkgs, ... }:

let
  # Get the hostname of the NixOS system
  hostname = config.networking.hostName;

  # Path to the secret file
  secretFilePath = "/etc/nixos/slack-webhook-url.nix";

  # Check if the secret file exists
  secretFileExists = builtins.pathExists secretFilePath;

  # Conditionally read the secret file
  slackWebhookUrl = if secretFileExists
                    then builtins.readFile secretFilePath
                    else null;
in

{

  # Conditionally define the systemd service and timer
  systemd.services = lib.mkIf secretFileExists {
    disk-usage-monitor = {
      description = "Monitor disk usage and send Slack notifications";
      path = with pkgs; [ curl ];
      script = ''
        disk_usage=$(df -h / | sed -n '2s/.* \([0-9]*\)%/\1/p' | tr -d '/')
        echo "Disk usage is $disk_usage"
        if [ "$disk_usage" -gt 80 ]; then
            echo "Disk Usage above 80%, sending Slack message"

            # Send Slack notification using curl
            curl -X POST -H 'Content-type: application/json' --data '{"text":"Disk Usage above 80% on ${hostname}"}' "${slackWebhookUrl}"

        fi
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };

  systemd.timers = lib.mkIf secretFileExists {
    disk-usage-monitor = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";  # Run once a day
        Unit = "disk-usage-monitor.service";
      }; 
    };
  };
}
