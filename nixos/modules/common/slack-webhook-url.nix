{ lib, ... }:

with lib;

{
  options = {
    slackWebhookUrl = mkOption {
      type = types.str;
      default = "";
      description = "Slack Webhook URL";
    };
  };

  config = {
    slackWebhookUrl = ""; # Place slack wehbook url here
  };
}