{ nd, ... }: {
  nd.ios = {
    nixos =
{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = {
    services.usbmuxd = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      libheif
      libimobiledevice
      ifuse
    ];
  };
}
;
  };
}
