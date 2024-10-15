{ pkgs, stdenv, efibootmgr, lib, makeDesktopItem, ...}:

let

  desktopItem = makeDesktopItem {
    name = "Reboot to Windows";
    desktopName = "Reboot to Windows";
    exec = "reboot-to-windows";
    comment = "Reboot to Windows";
    genericName = "Desktop application to quickly reboot to Windows";
    categories = ["Utility"];
  };

in

stdenv.mkDerivation {
  pname = "reboot-to-windows";
  version = "1.0.0";

  buildInputs = [ pkgs.efibootmgr ];

  src = pkgs.writeShellApplication {
    name = "reboot-to-windows";
    runtimeInputs = [ pkgs.efibootmgr ];
    text = ''
      #!/bin/sh
      set -e

      echo "Changing boot order to: Windows Boot Manager, PreLoader, Linux Boot Manager"
      windows_boot=$(efibootmgr | grep -i "Windows Boot Manager" | grep -oP 'Boot\\K\\d+')
      preloader_boot=$(efibootmgr | grep -i "PreLoader" | grep -oP 'Boot\\K\\d+')
      linux_boot=$(efibootmgr | grep -i "Linux Boot Manager" | grep -oP 'Boot\\K\\d+')

      boot_order="''${windows_boot}"
      if [ -n "$preloader_boot" ]; then
        boot_order="''${boot_order},''${preloader_boot}"
      fi
      if [ -n "$linux_boot" ]; then
        boot_order="''${boot_order},''${linux_boot}"
      fi

      efibootmgr -o "''${boot_order}" >/dev/null 2>&1

      # echo "Rebooting the system"
      # systemctl reboot
    '';
  };
    

  installPhase = ''
    runHook PreInstall

    # Install script
    cp -a . $out

    # Create Desktop Item
    mkdir -p "$out/share/applications"
    cp -a ${desktopItem} $out/share/applications/
  '';

  meta = with pkgs.lib; {
    description = "A tool to change the EFI boot order and reboot the system";
    license = licenses.mit;
    maintainers = with maintainers; [ timoverbrugghe ];
  };
}
