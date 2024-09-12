params@{ config, pkgs, inputs, channels, ... }: {
  environment.systemPackages = with pkgs; [
    imagemagick
    powertop
    acpi # seems to provide more accurate charging status than upower. see the underpowered anker charger
    (discord.override {
      withTTS = false;
    })
    #jetbrains.idea-community
    chromium
    inputs.agenix.packages.x86_64-linux.default
    dnsutils # nslookup
    silver-searcher
    transmission-gtk
    nixpkgs-fmt
    rustc
    cargo
    xclip
    ventoy-full
    # minecraft
    # prismlauncher
    libva-utils
    xorg.xev
    get_iplayer
    wol
    # hledger
    # haskellPackages.hledger-flow

    vlc
    podman-compose
    docker-compose
    moonlight-qt
    nix-tree
    libreoffice
    vscode
    nodejs_22

  ];

}
