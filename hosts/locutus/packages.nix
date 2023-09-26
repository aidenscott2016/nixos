inputs@{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    imagemagick
    powertop
    chromium
    jq
    acpi # seems to provide more accurate charging status than upower. see the underpowered anker charger
    terraform
    #postman
    discord
    calibre
    tor-browser-bundle-bin
    monero-gui
    hledger
    googleearth-pro

    gpsbabel-gui
    jetbrains.idea-community
    ventoy

  ];
}
