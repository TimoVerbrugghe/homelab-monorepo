{ config, pkgs, ... }:

{
  # Console, layout options
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Brussels";
  console.keyMap = "be-latin1";
}