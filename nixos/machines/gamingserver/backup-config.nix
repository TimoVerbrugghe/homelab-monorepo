{ config, pkgs, ... }:

let
  nasURL = "truenas.local.timo.be";
  nasBackupDir = "/mnt/X.A.N.A./backup-gamingserver";
  nasROMsDir = "/mnt/X.A.N.A./media/games/ROMs";
  ROMsDir = "/home/gamer/ROMs";
in

{
  ## Packages needed for backup
  environment.systemPackages = with pkgs; [
    gnutar
    mount
    rsync
    umount
  ];

  systemd.services.backup-gamingserver = {
    description = "Backup gamingserver core directories";
    requires = [ "network.target" ];
    script = ''
    
    # Setting up backup & exclude directories
      backup_dirs=(
        "/home/gamer/ES-DE"
        "/home/gamer/.config/Cemu"
        "/home/gamer/.config/citra-emu"
        "/home/gamer/.config/dolphin-emu"
        "/home/gamer/.config/melonDS"
        "/home/gamer/.config/mgba"
        "/home/gamer/.config/PCSX2"
        "/home/gamer/.config/ppsspp"
        "/home/gamer/.config/retroarch"
        "/home/gamer/.config/rpcs3"
        "/home/gamer/.config/Ryujinx"
        "/home/gamer/.config/sunshine"
        "/home/gamer/.local/share/Cemu"
        "/home/gamer/.local/share/citra-emu"
        "/home/gamer/.local/share/dolphin-emu"
        "/home/gamer/.local/share/duckstation"
        "/home/gamer/.local/share/Steam"
        "/home/gamer/.local/share/xemu"
      )

      # Exclude the steamapps subdirectory
      exclude_dirs=(
        "/home/gamer/.local/share/Steam/steamapps"
      )

      # Mounting NFS share
      temp_dir_mount=$(mktemp -d)
      ${pkgs.mount}/bin/mount -t nfs ${nasURL}:${nasBackupDir} $temp_dir_mount

      temp_dir_tar=$(mktemp -d)
      output_tar="$temp_dir_tar/gamer_backup.tar"

      # Creating tar archive
      echo "Starting backup"
      ${pkgs.gnutar}/bin/tar --verbose --exclude="''${exclude_dirs[@]}" -cf "$output_tar" "''${backup_dirs[@]}"

      # Check if the tar creation was successful
      if [ $? -eq 0 ]; then
        ${pkgs.rsync}/bin/rsync -avhP $output_tar $temp_dir_mount/gamer_backup.tar

        # Check if rsync was successful
        if [ $? -eq 0 ]; then
          ${pkgs.umount}/bin/umount $temp_dir_mount
          echo "Backup completed successfully. Archive saved at: $output_tar"
        else
          echo "Failed moving backup archive to NAS share"
        fi

      else
        echo "Backup failed."
      fi

      # Clean Up
      rm -rf $temp_dir_mount
      rm -rf $temp_dir_tar

    '';

    serviceConfig = {
      Type = "oneshot";
    };

  };

  # Backup gamingserver config directories on a monthly basis
  systemd.timers.backup-gamingserver = {
    description = "Backup gamingserver config directories on a monthly basis";
    timerConfig = {
      OnCalendar = "monthly";
      Unit = "backup-gamingserver.service";
    };
  };

  systemd.services.restore-gamingserver = {
    description = "Restore gamingserver core directories";
    requires = [ "network.target" ];
    script = ''
      # Temporary directory for mounting nfs share
      temp_dir_mount=$(mktemp -d)
      ${pkgs.mount}/bin/mount -t nfs ${nasURL}:${nasBackupDir} $temp_dir_mount

      # Input tar file to restore
      input_tar="$temp_dir_mount/gamer_backup.tar"

      # Temp dir to put tar file
      temp_dir_tar=$(mktemp -d)

      # Rsync tar file from NAS server to local machine
      ${pkgs.rsync}/bin/rsync -avhP $input_tar $temp_dir_tar/gamer_backup.tar

      # Temporary directory for extraction
      temp_dir_extract=$(mktemp -d)

      # Extract the tar archive
      ${pkgs.gnutar}/bin/tar -xf "$temp_dir_tar/gamer_backup.tar" -C "$temp_dir_extract"

      # Restore each directory to its original location
      restore_dirs=(
        "/home/gamer/ES-DE"
        "/home/gamer/.config/Cemu"
        "/home/gamer/.config/citra-emu"
        "/home/gamer/.config/dolphin-emu"
        "/home/gamer/.config/melonDS"
        "/home/gamer/.config/mgba"
        "/home/gamer/.config/PCSX2"
        "/home/gamer/.config/ppsspp"
        "/home/gamer/.config/retroarch"
        "/home/gamer/.config/rpcs3"
        "/home/gamer/.config/Ryujinx"
        "/home/gamer/.config/sunshine"
        "/home/gamer/.local/share/Cemu"
        "/home/gamer/.local/share/citra-emu"
        "/home/gamer/.local/share/dolphin-emu"
        "/home/gamer/.local/share/duckstation"
        "/home/gamer/.local/share/Steam"
        "/home/gamer/.local/share/xemu"
      )

      for dir in "''${restore_dirs[@]}"; do
        # Ensure the target directory exists
        mkdir -p "$dir"
        
        # Restore files from temp_dir to the original location
        ${pkgs.rsync}/bin/rsync -avhP "$temp_dir_extract/$dir/" "$dir"
      done

      # Clean up
      ${pkgs.umount}/bin/umount $temp_dir_mount
      rm -rf $temp_dir_mount
      rm -rf $temp_dir_tar
      rm -rf $temp_dir_extract

      echo "Restoration completed successfully."
    '';

    serviceConfig = {
      Type = "oneshot";
    };
    
  };

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