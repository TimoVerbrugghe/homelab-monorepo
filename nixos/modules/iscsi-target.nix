{ config, lib, pkgs, ... }:

{
  # Enable iSCSI target service
  services.target = {
    enable = true;
  };

  # Configure iSCSI target
  systemd.services.target-setup = {
    description = "Setup iSCSI target for testing";
    after = [ "target.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Create directory for iSCSI backing store
      mkdir -p /home/odd/iscsi
      
      # Create 10GB backing file if it doesn't exist
      if [ ! -f /home/odd/iscsi/disk.img ]; then
        ${pkgs.coreutils}/bin/dd if=/dev/zero of=/home/odd/iscsi/disk.img bs=1M count=10240
      fi
      
      # Configure target using targetcli
      ${pkgs.targetcli}/bin/targetcli <<EOF
        /backstores/fileio create iscsi-test /home/odd/iscsi/disk.img 10G
        /iscsi create iqn.2025-12.be.timo.local:iscsi-test
        /iscsi/iqn.2025-12.be.timo.local:iscsi-test/tpg1/luns create /backstores/fileio/iscsi-test
        /iscsi/iqn.2025-12.be.timo.local:iscsi-test/tpg1/acls create iqn.2005-03.org.open-iscsi:*
        /iscsi/iqn.2025-12.be.timo.local:iscsi-test/tpg1 set attribute authentication=0 demo_mode_write_protect=0 generate_node_acls=1 cache_dynamic_acls=1
        saveconfig
        exit
      EOF
    '';
  };

  # Open iSCSI port
  networking.firewall.allowedTCPPorts = [ 3260 ];
}
