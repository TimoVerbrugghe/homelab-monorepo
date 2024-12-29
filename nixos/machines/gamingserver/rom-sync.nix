{ config, pkgs, ... }:

let
  nasURL = "truenas.local.timo.be";
  nasROMsDir = "/mnt/X.A.N.A./media/games/ROMs";
  ROMsDir = "/home/gamer/ROMs";
in

{
  systemd.services.rom-sync = {
    description = "Sync ROMs directory with NAS ";
    requires = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      # Temporary directory for mounting nfs share
      temp_dir_mount=$(mktemp -d)
      ${pkgs.mount}/bin/mount -t nfs ${nasURL}:${nasROMsDir} $temp_dir_mount

      # Rsync contents of ROMs dir locally to ROMs dir on NAS to f.e. sync over savegames that are stored with the ROMs folder
      ${pkgs.rsync} -avhP --no-o --no-g ${ROMsDir}/ $temp_dir_mount/

      # Rsync contents of ROMs dir on the NAS to system locally to sync over new games that might have been added
      ${pkgs.rsync} -avhP $temp_dir_mount/ ${ROMsDir}/

        # Check if rsync was successful
        if [ $? -eq 0 ]; then
          ${pkgs.umount}/bin/umount $temp_dir_mount
          echo "ROMs directory sync successful"
        else
          echo "Failed moving backup archive to NAS share"
        fi

      # Clean up
      rm -rf $temp_dir_mount
    '';
  };

  # Do ROMs sync weekly
  systemd.timers.rom-sync = {
    description = "Sync ROMs folder on a weekly basis";
    timerConfig = {
      OnCalendar = "weekly";
      Unit = "rom-sync.service";
    };
  };

}