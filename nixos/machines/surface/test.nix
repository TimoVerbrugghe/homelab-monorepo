{ config, pkgs, ... }:

{
  nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              (pkgs.writeText "bg.patch" ''
                --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                @@ -15,4 +15,5 @@ $_gdm_dialog_width: 23em;
                 /* Login Dialog */
                 .login-dialog {
                   background-color: $_gdm_bg;
                +  background-image: url('file:///etc/nixos/lockscreen.png');
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
}