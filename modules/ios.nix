{ ... }:
{
  flake.modules.nixos.ios =
    { pkgs, lib, config, ... }:
    with pkgs;
    {
        services.usbmuxd = {
          enable = true;
        };

        environment.systemPackages =  [
          libheif
          libimobiledevice
          ifuse
        ];
    };
}
