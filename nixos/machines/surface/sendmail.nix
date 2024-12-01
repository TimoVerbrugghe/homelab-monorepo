{ config, pkgs, ... }:

{
  services.postfix = {
    enable = true;
    rootAlias = "root";
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

  environment.etc."postfix/sasl_passwd" = {
    text = "[smtp.gmail.com]:587 your_email@gmail.com:$(cat /etc/nixos/gmailpassword)";
    mode = "0600";
  };

  # Add the necessary packages
  environment.systemPackages = with pkgs; [
    postfix
    bsd-mailx  # For sending emails
  ];
}
