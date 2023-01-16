{ lib, pkgs, config, ... }:
{
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };
}
