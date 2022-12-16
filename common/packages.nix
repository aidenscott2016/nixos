{ config, pkgs, maimpick, ... }:
{
  environment.systemPackages = with pkgs; [
    #maimpick.packages.x86_64-linux.maimpick
    maimpick
    pgcli
    jetbrains.idea-community
    slock
    vim
    wget
    emacs
    git
    firefox
    arandr
    st
    pavucontrol
    spotify
    pass
    pinentry-gtk2
    nixpkgs-fmt
    tmux
    libimobiledevice
    ifuse
    tor-browser-bundle-bin
    scala
    sbt
    xorg.xbacklight
    metals
    #unstable.monero-gui
    file
    pcmanfm
    libheif
    imagemagick
    nicotine-plus
    vlc
    hledger
    hledger-web
    powertop
    coreboot-utils
    flashrom
    bintools-unwrapped
    slack
    chromium
    libreoffice
    scrot
    jetbrains.phpstorm
    php
    jq
    steam
    docker-compose
    xdotool
    dmenu
    i3lock
    libnotify
    psmisc
    dunst
    acpi # seems to provide more accurate charging status than upower. cf the underpowered anker charger
    cbatticon
    pamixer
    xsettingsd
  ];
}
