{ nd, ... }: {
  nd.yubikey = {
    nixos =
{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
    # smart card
    services.pcscd.enable = true;
    security.polkit.enable = true;
    environment.systemPackages = with pkgs; [ yubikey-manager ];
  };
}
;
  };
}
