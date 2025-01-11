## Aelita is a HA VM in my proxmox cluster that only does the following: 
# 1) expose an NFS server which will be used as my HA storage in my kubernetes cluster
# 2) Run Plex & Jellyfin because they use sqlite databases and they're unstable if those databases are on NFS

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "aelita";
  username = "aelita";
  hashedPassword = "$y$j9T$Q2d7p39EZ1FvibfhyrQNB1$K5tu7VuyiCaH3fnCwhOA6qYnfNDeYjE3.tYRbYHRBxB";
  ipAddress = "10.10.10.12";

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/vm-options.nix # Some default options you should enable on VMs
      ../../modules/common/autoupgrade.nix # Enable auto-upgrades
      ../../modules/common/boot.nix # Boot configuration
      ../../modules/common/dns.nix # DNS configuration
      ../../modules/common/firmware.nix # Firmware configuration
      ../../modules/common/flakes.nix # Enable Flakes
      ../../modules/common/graylog.nix # Graylog configuration
      ../../modules/common/networking.nix # Networking configuration
      ../../modules/common/optimizations.nix # Optimization configuration
      ../../modules/common/packages.nix # Package configuration
      ../../modules/common/ssh.nix # SSH configuration
      ../../modules/common/user.nix # User configuration
      ../../modules/common/vars.nix # Variables configuration
      ../../modules/intel-gpu-drivers.nix # Intel GPU Drivers
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "24.11";
  
  networking.hostName = "${hostname}"; # Define your hostname.
  hardware.cpu.intel.updateMicrocode = true;
  console.keyMap = "be-latin1";

  # Set up single user using user.nix module
  services.user = {
    user = "${username}";
    hashedPassword = "${hashedPassword}";
  };

  ## Enable AutoUpgrades using autoupgrade.nix module
  services.autoUpgrade = {
    hostname = "${hostname}";
  };

  ## Networking setup
  networking = {
    usePredictableInterfaceNames = false;
    defaultGateway = "${config.vars.defaultGateway}";
    interfaces = {
      eth0 = {
        ipv4.addresses  = [
          { address = "${ipAddress}"; prefixLength = 24; }
        ];
      };
    };
  };

  ### NFS Setup for Kubernetes (this node is a HA node on proxmox providing storage to my kubernetes cluster)
  # Creating directories on the system - having "-" at the end tells systemd not to delete these folders
  systemd.tmpfiles.rules = [
    "d /nfs 0770 nobody nogroup -"
    "d /nfs/portainer 0770 nobody nogroup -"
    "d /nfs/bitwarden 0770 nobody nogroup -"
    "d /nfs/bitwarden-export 0770 nobody nogroup -"
  ];

  # NFS Server Configuration
  services.nfs.server.enable = true;
  networking.firewall.allowedTCPPorts = [ 2049 ];
  services.nfs.server.exports = ''
    /nfs                  ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
    /nfs/portainer        ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
    /nfs/bitwarden        ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
    /nfs/bitwarden-export ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
  '';

  #### Plex Setup #####
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  
  boot.devShmSize = "70%"; # More ram for plex to transcode in
  
  # Mount movies & tvshows from my NAS
  fileSystems."/movies" = {
    device = "nfs.local.timo.be:/mnt/X.A.N.A./media/movies";
    fsType = "nfs";
    options = [ "rw" "vers=4.2" "relatime" "sec=sys" "hard" ];
  };

  fileSystems."/tvshows" = {
    device = "nfs.local.timo.be:/mnt/X.A.N.A./media/tvshows";
    fsType = "nfs";
    options = [ "rw" "vers=4.2" "relatime" "sec=sys" "hard" ];
  };

  fileSystems."/music" = {
    device = "nfs.local.timo.be:/mnt/X.A.N.A./media/tvshows";
    fsType = "nfs";
    options = [ "rw" "vers=4.2" "relatime" "sec=sys" "hard" ];
  };

  # Systemd service to create a tar file of /var/lib/plex and rsync it to the NFS server  
  systemd.services.plex-backup = {
    description = "Backup Plex data and sync to NFS server";
    path = with pkgs; [
      rsync
      tar
    ];
    script = ''
      BACKUP_DIR="/var/lib/plex"
      BACKUP_FILE="/tmp/plex-backup-$(date +%Y%m%d).tar.gz"
      NFS_TARGET="nfs.local.timo.be:/mnt/FranzHopper/appdata/plex-$(date +%Y%m%d).tar.gz"
      
      # Create tar file
      tar -czf $BACKUP_FILE -C $BACKUP_DIR .
      
      # Rsync to NFS server
      rsync -avz $BACKUP_FILE $NFS_TARGET
      
      # Remove old backups, keep only the last 3
      ssh nfs.local.timo.be "ls -t /mnt/FranzHopper/appdata/plex-*.tar.gz | tail -n +4 | xargs rm -f"
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Systemd timer to run the backup service daily
  systemd.timers.plex-backup-timer = {
    description = "Daily backup of Plex data";
    wants = [ "plex-backup.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    unitConfig = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Systemd service to create a tar file of /var/lib/jellyfin and rsync it to the NFS server  
  systemd.services.jellyfin-backup = {
    description = "Backup jellyfin data and sync to NFS server";
    path = with pkgs; [
      rsync
      tar
    ];
    script = ''
      BACKUP_DIR="/var/lib/jellyfin"
      BACKUP_FILE="/tmp/jellyfin-backup-$(date +%Y%m%d).tar.gz"
      NFS_TARGET="nfs.local.timo.be:/mnt/FranzHopper/appdata/jellyfin-$(date +%Y%m%d).tar.gz"
      
      # Create tar file
      tar -czf $BACKUP_FILE -C $BACKUP_DIR .
      
      # Rsync to NFS server
      rsync -avz $BACKUP_FILE $NFS_TARGET
      
      # Remove old backups, keep only the last 3
      ssh nfs.local.timo.be "ls -t /mnt/FranzHopper/appdata/jellyfin-*.tar.gz | tail -n +4 | xargs rm -f"
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Systemd timer to run the backup service daily
  systemd.timers.jellyfin-backup-timer = {
    description = "Daily backup of jellyfin data";
    wants = [ "jellyfin-backup.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    unitConfig = {
      WantedBy = [ "timers.target" ];
    };
  };

}
