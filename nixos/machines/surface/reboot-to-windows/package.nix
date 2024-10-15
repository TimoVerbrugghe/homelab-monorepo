{ stdenv, efibootmgr, lib, makeDesktopItem, writeShellApplication, ...}:

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

  buildInputs = [ efibootmgr ];

  dontBuild = true;
  dontConfigure = true;

  src = writeShellApplication {
    name = "reboot-to-windows";
    runtimeInputs = [ efibootmgr ];
    text = ''
      echo "Changing boot order to: Windows Boot Manager, PreLoader, Linux Boot Manager"
      windows_boot=$(efibootmgr | grep -i "Windows Boot Manager" | grep -oP 'Boot\K\d+')
      preloader_boot=$(efibootmgr | grep -i "PreLoader" | grep -oP 'Boot\K\d+')
      linux_boot=$(efibootmgr | grep -i "Linux Boot Manager" | grep -oP 'Boot\K\d+')

      boot_order="''${windows_boot}"
      if [ -n "$preloader_boot" ]; then
        boot_order="''${boot_order},''${preloader_boot}"
      fi
      if [ -n "$linux_boot" ]; then
        boot_order="''${boot_order},''${linux_boot}"
      fi

      sudo efibootmgr -o "''${boot_order}"

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
    cp -a ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = with lib; {
    description = "A tool to change the EFI boot order and reboot the system";
    license = licenses.mit;
    maintainers = with maintainers; [ timoverbrugghe ];
  };
}
