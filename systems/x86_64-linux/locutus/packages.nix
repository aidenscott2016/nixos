params@{ config, pkgs, inputs, channels, ... }: {
  environment.systemPackages = with pkgs; [
    (jellyfin-media-player.override {
      withDbus = false;
    })
    imagemagick
    powertop
    acpi # seems to provide more accurate charging status than upower. see the underpowered anker charger
    discord
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
  ];

}
