{ config, lib, pkgs, ... }:

let
  # Get the hostname of the NixOS system
  hostname = config.networking.hostName;

in {

  imports =[ 
      # Include cloudflare API key file, you need to put this manually in your nixos install
      /etc/nixos/teams-webhook-url.nix
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
      if [ "$disk_usage" -gt 10 ]; then
          echo "Disk Usage above 80%, sending teams message"

          # Construct the Adaptive Card payload
          adaptive_card='{
              "type":"message",
              "attachments":[
                  {
                      "contentType":"application/vnd.microsoft.card.adaptive",
                      "contentUrl":null,
                      "content":{
                          "type": "AdaptiveCard",
                          "body": [
                              {
                                  "type": "TextBlock",
                                  "size": "ExtraLarge",
                                  "weight": "Bolder",
                                  "text": "Disk Usage Alert",
                                  "style": "heading",
                                  "wrap": true
                              },
                              {
                                  "type": "TextBlock",
                                  "text": "Disk usage is above 80% on ${hostname}",
                                  "wrap": true
                              },
                              {
                                  "type": "FactSet",
                                  "facts": [
                                      {
                                          "title": "Hostname:",
                                          "value": "${hostname}"
                                      },
                                      {
                                          "title": "Disk Usage",
                                          "value": "$disk_usage"
                                      }
                                  ]
                              }
                          ],
                          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                          "version": "1.6"
                          }
                      }
              ]
          }'

          # Send Teams notification using curl
          curl -X POST -H 'Content-type: application/json' --data "$adaptive_card" "${config.teamsWebhookUrl}"

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
