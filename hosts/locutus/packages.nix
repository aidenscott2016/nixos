inputs@{ config, pkgs, agenix, ... }: {
  environment.systemPackages = with pkgs; [
    imagemagick
    powertop
    #google-chrome chromium is not cached?
    #    jq
    acpi # seems to provide more accurate charging status than upower. see the underpowered anker charger
    #terraform
    #postman
    discord
    #calibre -- includes speech synthesiser bloat
    # tor-browser-bundle-bin
    # monero-gui
    #    hledger
    #googleearth-pro

    #    gpsbabel-gui
    jetbrains.idea-community
    #    ventoy
    chromium
    agenix.packages.x86_64-linux.default

  ];
}
