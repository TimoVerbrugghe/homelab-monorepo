{ config, pkgs, lib, ... }:

{
  
  # Enable gnome desktop manager
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      # Enable fractional scaling
      extraGSettingsOverridePackages = [ pkgs.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
    };
  };

  services.gnome = {
    sushi.enable = true; # Enable file preview
  };
  
  # Gnome Extensions
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.window-gestures
    gnome-power-manager # Get battery graphs
  ];

  # Packages from gnome to exclude
  environment.gnome.excludePackages = with pkgs; [
    baobab            # disk usage analyzer
    cheese      # photo booth
    epiphany          # web browser
    totem       # video player
    yelp        # help viewer
    evince            # document viewer
    geary       # email client
    seahorse    # password manager

    # these should be self explanatory 
    gnome-contacts
    gnome-maps 
    gnome-music 
    gnome-photos
    gnome-weather
    gnome-tour
    
  ];

  # Set a wallpaper on the gnome login screen (gdm), which is a custom patch you need to apply in gnome
  environment.etc = {
    ".lockscreen.png" = {
      source = ./wallpapers/msft-dev-home-wave-lockscreen.png;
      mode = "0644";
    };
    ".wallpaper.png" = {
      source = ./wallpapers/msft-dev-home-wave.png;
      mode = "0644";
    };
    ".avatar.png" = {
      source = ./wallpapers/avatar.png;
      mode = "0644";
    };
    ".Timo" = {
      text = ''
        [User]
        Session=
        Icon=/var/lib/AccountsService/icons/Timo
        SystemAccount=false
      '';
      mode = "0644";
    };
  };
  
  # nixpkgs = {
  #   overlays = [
  #     (self: super: {
  #       gnome-shell = super.gnome-shell.overrideAttrs (old: {
  #         patches = (old.patches or []) ++ [
  #           (pkgs.writeText "bg.patch" ''
  #             --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
  #             +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
  #             @@ -15,4 +15,8 @@ $_gdm_dialog_width: 23em;
  #             /* Login Dialog */
  #             .login-dialog {
  #               background-color: $_gdm_bg;
  #             +  background-image: url('file:///etc/.lockscreen.png');
  #             +  background-size: cover;
  #             +  background-position: center;
  #             +  background-repeat: no-repeat;
  #             }
  #           '')
  #         ];
  #       });
  #     })
  #   ];
  # };


  # Set an user avatar for the login screen by copying avatar image & user file to the right location
  system.activationScripts.gnomeAvater = lib.stringAfter [ "var" ] ''
    cp /etc/.avatar.png /var/lib/AccountsService/icons/Timo
    cp /etc/.Timo /var/lib/AccountsService/users/Timo
  '';

}