params@{ pkgs, lib, config, inputs, ... }:

with lib.aiden;
with pkgs;
let
  steamtinkerlaunch-git = pkgs.steamtinkerlaunch.overrideAttrs
    (_: { src = inputs.steamtinkerlaunch; });
in enableableModule "steam" params {
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ steamtinkerlaunch-git ];
  };
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;
  environment.systemPackages = [
    #steamtinkerlaunch
    python312Packages.ds4drv
    python3
  ];

}
