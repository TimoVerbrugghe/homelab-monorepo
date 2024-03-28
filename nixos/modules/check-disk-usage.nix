{ config, lib, pkgs, ... }:

let
  # Define the Slack webhook URL where notifications will be sent
  slackWebhook = "https://hooks.slack.com/services/YOUR_WEBHOOK_URL_HERE";

  # Get the hostname of the NixOS system
  hostname = config.networking.hostName;

in {

  # Define the systemd service
  systemd.services.disk-usage-monitor = {
    description = "Monitor disk usage and send Slack notifications";
    script = ''
      # Check disk usage (adjust the path as needed)
      disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
      if [ "$disk_usage" -gt 80 ]; then
        # Construct the Slack message
        title="Disk Usage Alert on ${hostname}"
        message="Disk usage is above 80%!"
        payload="{\"text\": \"$title\n$message\"}"
        # Send Slack notification
        curl -X POST -H 'Content-type: application/json' --data "$payload" $slackWebhook
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
    };
    unit = "disk-usage-monitor.service";
  };
}
