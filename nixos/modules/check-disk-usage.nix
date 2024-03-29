{ config, lib, pkgs, ... }:

let
  # Get the hostname of the NixOS system
  hostname = config.networking.hostName;
  ipAddress = config.networking.interfaces.eth0.ipv4_addresses[0].address;

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
      echo
    ];
    script = ''
      disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
      echo "Disk usage is $disk_usage"
      if [ "$disk_usage" -gt 80 ]; then
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
                                          "title": "IP",
                                          "value": "${ipAddress}"
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
    };
    unit = "disk-usage-monitor.service";
  };
}
