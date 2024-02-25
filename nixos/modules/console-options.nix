{ config, pkgs, ... }:

{
  # Console, layout options
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "be-latin1";
  time.timeZone = "Europe/Brussels";
}