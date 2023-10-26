params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "ios" params {
  services.usbmuxd = { enable = true; };

  environment.systemPackages = with pkgs; [ libheif libimobiledevice ifuse ];
}
