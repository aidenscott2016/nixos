{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  environment.systemPackages = with pkgs; [
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
    unstable.monero-gui
    file
    flyway
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
  ];
}
