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
    gamescopeSession.enable = true;
    extraCompatPackages = [ steamtinkerlaunch-git ];
    environment.systemPackages = [ steamtinkerlaunch-git ];
  };
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;
}
