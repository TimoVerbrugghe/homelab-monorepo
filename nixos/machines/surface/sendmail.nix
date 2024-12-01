{ config, pkgs, ... }:

{
  services.postfix = {
    enable = true;
    rootAlias = "root";
    mapFiles."sasl_passwd" = builtins.readFile /etc/nixos/gmailpassword;
    config = {
      relayhost = "[smtp.gmail.com]:587";
      smtp_use_tls = "yes";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
      smtp_sasl_security_options = "noanonymous";
      smtp_tls_security_level = "encrypt";
      smtp_tls_note_starttls_offer = "yes";
    };
  };
}
