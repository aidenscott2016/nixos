params@{ pkgs, lib, config, ... }:
with lib.aiden;
with pkgs;
enableableModule "steam" params {
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ steamtinkerlaunch ];
  };
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;
  environment.systemPackages = [
    #steamtinkerlaunch
    python312Packages.ds4drv
    python3
  ];

}
