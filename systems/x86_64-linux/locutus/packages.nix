params@{ config, pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    (jellyfin-media-player.override {
      withDbus = false;
    })
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
    inputs.agenix.packages.x86_64-linux.default

    dnsutils # nslookup
    silver-searcher
    transmission-gtk
    nixpkgs-fmt
    rustc
    cargo
    xclip
    ventoy-full
    minecraft
    prismlauncher
    libva-utils
    xorg.xev
    get_iplayer
    wol
  ];

}
