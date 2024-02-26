{ lib, ... }:

with lib;
with types;

{

  

  options = {
    vars = mkOption {
      type = attrs;
      description = "My config attrs";
    };
  };

  config = {
    vars = {
      tailscaleDomain = "pony-godzilla.ts.net";
      sshKeysUrl = "https://github.com/TimoVerbrugghe.keys";
      sshKeysSHA = "sha256-agx4WrtOqchQCUgn0FqlRE3hcmvG9b+Fm5D/sVMy94U=";
      gitUserName = "TimoVerbrugghe";
      gitUserEmail = "timo@hotmail.be";
      defaultGateway = "10.10.10.1";
    };
  };

}