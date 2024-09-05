{ config, pkgs, ... }:

{
  # Mount the NFS share
  fileSystems."/mnt/music" = {
    device = "nfs.local.timo.be:/mnt/X.A.N.A./media/music/spotdl";
    fsType = "nfs";
    options = "rw";
  };

  # Install spotdl package
  environment.systemPackages = [ pkgs.spotdl ];

  # Configure the spotdl service
  systemd.services.spotdl = {
    description = "Sync Spotify Liked Songs Playlist with NFS share";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    enable = true;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.spotdl}/bin/spotdl download ${config.services.spotdl.playlistUrl}";
      Restart = "on-failure";
      WorkingDirectory = "/mnt/music";
    };
  };

  # Configure the spotdl timer
  systemd.timers.spotdl = {
    description = "Spotdl Spotify Playlist Downloader Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 00:00:00";
      Persistent = true;
    };
    unitConfig = {
      Requires = [ "spotdl.service" ];
      After = [ "spotdl.service" ];
    };
  };
}