{ config, pkgs, ... }:

{

  ## Packages needed for backup
  environment.systemPackages = with pkgs; [
    gnutar
    mount
    rsync
  ];

  systemd.services.backup-gamingserver = {
    description = "Backup gamingserver core directories";
    requires = [ "network.target" ];
    script = ''
      mkdir -p /tmp/nfs
      ${pkgs.mount}/bin/mount -t nfs 10.10.10.2:/mnt/X.A.N.A./gamingserver-backup /tmp/nfs

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
      )

      # Exclude the steamapps subdirectory
      exclude_dirs=(
        "/home/gamer/.local/share/Steam/steamapps"
      )

      output_tar="/tmp/nfs/gamer_backup.tar.xz"

      ${pkgs.gnutar}/bin/tar --exclude="''${exclude_dirs[@]}" -cJf "$output_tar" "''${backup_dirs[@]}"

      # Check if the tar creation was successful
      if [ $? -eq 0 ]; then
        echo "Backup completed successfully. Archive saved at: $output_tar"
      else
        echo "Backup failed."
      fi

    '';

    serviceConfig = {
      type = "oneshot";
    };

  };

  # Backup gamingserver config directories on a monthly basis
  # systemd.timers.tailscale-cert-renewal = {
  #   description = "Backup gamingserver config directories on a monthly basis";
  #   timerConfig = {
  #     OnCalendar = "monthly";
  #     Unit = "backup-gamingserver.service";
  #   };
  # };

  systemd.services.restore-gamingserver = {
    description = "Restore gamingserver core directories";
    requires = [ "network.target" ];
    script = ''
      # Mount nfs share
      mkdir -p /tmp/nfs
      ${pkgs.mount}/bin/mount -t nfs 10.10.10.2:/mnt/X.A.N.A./gamingserver-backup /tmp/nfs

      # Input tar file to restore
      input_tar="/tmp/nfs/gamer_backup.tar.xz"

      # Temporary directory for extraction
      temp_dir=$(mktemp -d)

      # Extract the tar archive
      ${pkgs.gnutar}/bin/tar -xJf "$input_tar" -C "$temp_dir"

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
      )

      for dir in "''${restore_dirs[@]}"; do
        # Ensure the target directory exists
        mkdir -p "$dir"
        
        # Restore files from temp_dir to the original location
        ${pkgs.rsync}/bin/rsync -av "$temp_dir/$dir/" "$dir"
      done

      # Clean up temporary directory
      rm -rf "$temp_dir"

      echo "Restoration completed successfully."
    '';

    serviceConfig = {
      type = "oneshot";
    };
    
  };
}