{
  aiden.ios.nixos =
    { pkgs, ... }:
    {
      services.usbmuxd.enable = true;

      environment.systemPackages = with pkgs; [
        libheif
        libimobiledevice
        ifuse
      ];
    };
}
