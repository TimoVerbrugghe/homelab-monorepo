{ config, pkgs, ... }:

{
  # Enable and configure rsyslog
  services.rsyslogd = {
    enable = true;

    # Configure rsyslog to forward logs to Graylog
    extraConfig = ''
      *.* @graylog.local.timo.be:1517;RSYSLOG_SyslogProtocol23Format
    '';
  };

  # Ensure the log forwarding rules apply to all logs, including syslog and dmesg
  boot.kernelParams = [ "printk.devkmsg=on" ];
}
