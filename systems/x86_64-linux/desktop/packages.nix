{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Desktop packages (from desktop composition module)
    bindfs
    xorg.xev
    (discord.override { withTTS = false; })
    cameractrls-gtk3
    chromium
    xclip
    libreoffice
    kdePackages.okular
  ];
}
