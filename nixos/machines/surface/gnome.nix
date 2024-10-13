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
}