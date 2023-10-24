{ lib, pkgs, config, ... }: {
  services.usbmuxd = { enable = true; };

  environment.systemPackages = with pkgs; [ libheif libimobiledevice ifuse ];
}
