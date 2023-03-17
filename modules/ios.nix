{ lib, pkgs, config, ... }:
{
  services.usbmuxd = {
    enable = true;
  };
}
