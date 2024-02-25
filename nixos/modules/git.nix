{ config, pkgs, ... }:

{
  
  # Setup git
  programs.git = {
    enable = true;
    config = {
        user.name = "${config.vars.gitUserName}";
        user.email = "${config.vars.gitUserEmail}";
    };
  };


}