{ config, pkgs, ... }:

{
  hardware = {
    sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices = {
          home = { model = "DCP-L2627DWE"; ip = "10.10.10.197"; };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Scanner program more advanced than the gnome simple-scan
    naps2
  ];

  # Needed for naps2 to work
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];
}