{ lib, ... }:

with lib;

{
  options = {
    teamsWebhookUrl = mkOption {
      type = types.str;
      default = "";
      description = "Teams Webhook URL";
    };
  };

  config = {
    teamsWebhookUrl = ""; # Place teams wehbook url here
  };
}