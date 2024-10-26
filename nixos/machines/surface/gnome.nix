{ config, pkgs, ... }:

{
  # Enable gnome desktop manager
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      # Enable fractional scaling
      extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
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
    gnome.gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.window-gestures
    gnome.gnome-power-manager # Get battery graphs
  ];

  # Packages from gnome to exclude
  environment.gnome.excludePackages = with pkgs; [
    baobab            # disk usage analyzer
    gnome.cheese      # photo booth
    epiphany          # web browser
    gnome.totem       # video player
    gnome.yelp        # help viewer
    evince            # document viewer
    gnome.geary       # email client
    gnome.seahorse    # password manager

    # these should be self explanatory 
    gnome.gnome-contacts
    gnome.gnome-maps 
    gnome.gnome-music 
    gnome-photos
    gnome.gnome-weather
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
  
  nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              (pkgs.writeText "bg.patch" ''
                --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                @@ -15,4 +15,8 @@ $_gdm_dialog_width: 23em;
                 /* Login Dialog */
                 .login-dialog {
                   background-color: $_gdm_bg;
                +  background-image: url('file:///etc/.lockscreen.png');
                +  background-size: cover;
                +  background-position: center;
                +  background-repeat: no-repeat;
                 }
              '')
            ];
          });
        });
      })
    ];
  };

  # Set an user avatar for the login screen by copying avatar image & user file to the right location
  config.system.activationScripts.gnomeAvater = lib.stringAfter [ "var" ] ''
    cp /etc/.avatar.png /var/lib/AccountsService/icons/Timo
    cp /etc/.Timo /var/lib/AccountsService/users/Timo
  '';

}