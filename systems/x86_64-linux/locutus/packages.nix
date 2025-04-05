params@{ config, pkgs, inputs, channels, lib, ... }: {
  environment.systemPackages = with pkgs; [
    imagemagick

    # hardware
    powertop
    acpi # seems to provide more accurate charging status than upower. see the underpowered anker charger

    # desktop
    # communication
    (discord.override { withTTS = false; })
    cameractrls-gtk3
    

    #jetbrains.idea-community

    #desk top
    chromium

    # networking
    # hardware
    dnsutils # nslookup

    silver-searcher

    # media
    transmission-gtk
    get_iplayer
    vlc

    # nix, development
    nixpkgs-fmt
    nix-tree
    vscode
    nodejs_22

    # desktop
    xclip

    # hardware
    ventoy-full

    # gaming
    libva-utils
    xorg.xev

    # gaming, hardware
    wol
    # hledger
    # haskellPackages.hledger-flow

    # virt
    podman-compose
    docker-compose
    kubectl

    # productivity
    libreoffice
    okular

  ];

}
