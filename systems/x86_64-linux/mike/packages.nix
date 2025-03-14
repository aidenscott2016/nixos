params@{ config, pkgs, inputs, channels, lib, ... }: {
  environment.systemPackages = with pkgs; [
    powertop
    acpi # seems to provide more accurate charging status than upower. see the underpowered anker charger
    (discord.override { withTTS = false; })
    chromium
    inputs.agenix.packages.x86_64-linux.default
    dnsutils # nslookup
    silver-searcher
    transmission-gtk
    nixpkgs-fmt
    xclip
    libva-utils
    xorg.xev
    wol
    vlc
    podman-compose
    docker-compose
    moonlight-qt
    nix-tree
    libreoffice
    vscode
    nodejs_22
    calibre
    okular
    kubectl
    yubikey-manager
    bitwarden-desktop
  ];

}
