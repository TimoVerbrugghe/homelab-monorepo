{ config, pkgs, ... }:

let
  nasURL = "truenas.local.timo.be";
  nasromsDir = "/mnt/X.A.N.A./media/games/roms";
  romsDir = "/home/gamer/roms";
in

{
  systemd.services.rom-sync = {
    description = "Sync roms directory with NAS ";
    requires = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      # Temporary directory for mounting nfs share
      temp_dir_mount=$(mktemp -d)
      ${pkgs.mount}/bin/mount -t nfs ${nasURL}:${nasromsDir} $temp_dir_mount

      # Rsync contents of roms dir locally to roms dir on NAS to f.e. sync over savegames that are stored with the roms folder
      ${pkgs.rsync} -avhP --no-o --no-g ${romsDir}/ $temp_dir_mount/

      # Rsync contents of roms dir on the NAS to system locally to sync over new games that might have been added
      ${pkgs.rsync} -avhP $temp_dir_mount/ ${romsDir}/

        # Check if rsync was successful
        if [ $? -eq 0 ]; then
          ${pkgs.umount}/bin/umount $temp_dir_mount
          echo "roms directory sync successful"
        else
          echo "Failed moving backup archive to NAS share"
        fi

      # Clean up
      rm -rf $temp_dir_mount
    '';
  };

  # Do roms sync weekly
  systemd.timers.rom-sync = {
    description = "Sync roms folder on a weekly basis";
    timerConfig = {
      OnCalendar = "weekly";
      Unit = "rom-sync.service";
    };
  };

}