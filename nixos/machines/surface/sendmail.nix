# Need to put the following files at /etc/nixos
# /etc/nixos/gmailpassword: [smtp.gmail.com]:587 <EMAIL FROM SENDER>:<GOOGLE APP PASSWORD>
# /etc/nixos/mail: <RECEIVER EMAIL>

{ config, pkgs, ... }:

let

  emailMessage = pkgs.writeText "emailMessage" ''
    Hi David,

    The disk of your Plex server is almost full (over 95%!). You'll need to start deleting some older TV shows & movies if you want to download new ones. 
    You can do that through Sonarr (https://sonarr.mermaid-alpha.ts.net) for TV shows or Radarr (https://radarr.mermaid-alpha.ts.net).

    Best,
    Your Plex Server
  '';

in 

{
  # Setting up postfix for sending mails
  services.postfix = {
    enable = true;
    rootAlias = "root";
    mapFiles."sasl_passwd" = "/etc/nixos/gmailpassword";
    config = {
      relayhost = "[smtp.gmail.com]:587";
      smtp_use_tls = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
      smtp_sasl_security_options = "noanonymous";
      smtp_tls_security_level = "encrypt";
      smtp_tls_note_starttls_offer = "yes";
    };
  };

  # Mailutils needed for sending a mail within a script
  environment.systemPackages = with pkgs; [
    mailutils
  ];

  # Create the check_disk_usage.sh script
  systemd.services.check_disk_usage = {
    description = "Check Disk Usage and Send Alert Email";
    path = [
      pkgs.busybox
      pkgs.mailutils
    ];
    script = ''
      DISK_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')
      if [ "$DISK_USAGE" -gt 10 ]; then
        SUBJECT="Your Plex Server disk is almost full"
        EMAIL=$(cat /etc/nixos/email)
        MESSAGE=$(cat ${emailMessage})
        echo "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Schedule the check_disk_usage service to run daily
  systemd.timers.check_disk_usage = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };  
}