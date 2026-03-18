{ config, lib, pkgs, ... }:

let
  cfg = config.services.failureNotification;

  notifyScript = pkgs.writeShellScript "pushover-systemd-failure" ''
    set -euo pipefail

    failed_unit="$1"

    # Avoid recursion if this notifier unit itself fails.
    if [[ "$failed_unit" == failure-notification@* ]]; then
      exit 0
    fi

    token="$(tr -d '\r\n' < "${cfg.apiTokenFile}")"
    user="$(tr -d '\r\n' < "${cfg.userKeyFile}")"
    host="$(${pkgs.coreutils}/bin/hostname -f 2>/dev/null || ${pkgs.coreutils}/bin/hostname)"

    title="Systemd failure on $host"
    message="Unit '$failed_unit' entered failed state."

    args=(
      --fail
      --silent
      --show-error
      --retry 5
      --retry-all-errors
      --max-time 20
      --data-urlencode "token=$token"
      --data-urlencode "user=$user"
      --data-urlencode "title=$title"
      --data-urlencode "message=$message"
      --data-urlencode "priority=${toString cfg.priority}"
    )

    ${lib.optionalString (cfg.device != null) ''
      args+=(--data-urlencode "device=${cfg.device}")
    ''}

    ${lib.optionalString (cfg.sound != null) ''
      args+=(--data-urlencode "sound=${cfg.sound}")
    ''}

    ${pkgs.curl}/bin/curl "https://api.pushover.net/1/messages.json" "''${args[@]}"
  '';
in
{
  options.services.failureNotification = {
    enable = lib.mkEnableOption "Pushover notifications for failed systemd units";

    apiTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/pushover-api-token";
      description = "Path to file containing the Pushover application API token.";
    };

    userKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/pushover-user-key";
      description = "Path to file containing the Pushover user/group key.";
    };

    priority = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Pushover message priority (-2..2).";
    };

    device = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional target device name configured in Pushover.";
    };

    sound = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional Pushover sound name.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.apiTokenFile != null && cfg.userKeyFile != null;
        message = "services.failureNotification requires both apiTokenFile and userKeyFile.";
      }
    ];

    # Applies to units that do not explicitly define OnFailure.
    systemd.extraConfig = lib.mkAfter ''
      [Manager]
      DefaultOnFailure=failure-notification@%n.service
    '';

    systemd.services."failure-notification@" = {
      description = "Send Pushover notification for failed unit %I";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${notifyScript} %I";
        User = "root";
        Group = "root";
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectSystem = "full";
      };
    };
  };
}