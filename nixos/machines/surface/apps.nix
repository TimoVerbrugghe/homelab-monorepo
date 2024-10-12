{ config, pkgs, ... }:

{
  ## Additional packages
  environment.systemPackages = with pkgs; [
    (google-chrome.override 
      { commandLineArgs = [
        "--enable-features=TouchpadOverscrollHistoryNavigation" # Enable touchpad back/forward navigation
        "--ozone-platform=wayland" # Enable zoom in with 2 fingers touchpad
        ]
      }
    )
    p7zip
    bitwarden-desktop
    vscode
  ];
}
