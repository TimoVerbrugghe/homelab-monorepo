{ config, lib, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  # WARNING: Less stable on MacOS than homebrew
  environment.systemPackages = with pkgs; [ 
    vscode
    direnv
    iperf
    powershell
    nano
    kubernetes-helm
    kubectl
    ansible
    mas
    moonlight-qt
    spotify
    gimp
    google-chrome
    monitorcontrol
    maccy
    slack
    localsend
    hidden-bar
    talosctl
  ];
  
  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  programs.tmux.enable = true;

  ## Homebrew packages
  # For packages mentioned below to be installed, you need to FIRST install the following
  # xcode Command Line Tools: xcode-select --install
  # + Agreeing to the xcode license agreement: sudo xcodebuild -license accept
  # ANY Mac App: you NEED to have purchased or downloaded the app before from the app store, this INCLUDES free apps as well!
  homebrew = {
    enable = true;

    # Install mas cli to get Mac App Store IDs for masApps
    brews = [
    ];
    casks = [
      "tailscale-app"
      "vlc"
      "microsoft-edge"
      # "sony-ps-remote-play" - This still needs rosetta 
      "intune-company-portal"
      "bettertouchtool"
      "jabra-direct"
      "background-music"
      "microsoft-teams"
      "handbrake"
    ];
    masApps = {
      "Xcode" = 497799835;
      "Windows App" = 1295203466;
      "Microsoft Word" = 462054704;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Outlook" = 985367838;
      "Microsoft OneNote" = 784801555;
      "Microsoft OneDrive" = 823766827;
      "Microsoft To Do" = 1274495053;
      "Plexamp" = 1500797510;
      "Home Assistant" = 1099568401;
      "Microsoft Copilot" = 6738511300;
      "Microsoft Universal Print" = 6450432292;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "iMovie" = 408981434;
      "GarageBand" = 682658836;
      "Pushover" = 506088175;
      "Whatsapp" = 310633997;
      "Bitwarden"= 1352778147;
    };

    # Remove any casks that are not defined in this nix config
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };

}