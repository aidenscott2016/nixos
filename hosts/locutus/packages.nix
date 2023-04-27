inputs@{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    inputs.maimpick.packages."${system}".maimpick
    imagemagick
    powertop

    #slack
    chromium
    #jetbrains.phpstorm
    #php
    jq
    #steam
    acpi # seems to provide more accurate charging status than upower. see the underpowered anker charger
    terraform
    #postman
    #discord
    silver-searcher
    yt-dlp
    nixfmt

    ripgrep
  ];
}
