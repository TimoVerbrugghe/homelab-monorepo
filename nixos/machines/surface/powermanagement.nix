{ config, pkgs, ... }:

{

  # Power saving
  services.thermald.enable = true;

  ## You have set services.power-profiles-daemon.enable = true; which conflicts with services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = {
  #     governor = "powersave";
  #     turbo = "auto";
  #   };
  #   charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #   };
  # };

}