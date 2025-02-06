params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "steam" params {
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  environment.systemPackages = with pkgs; [ steamtinkerlaunch ];
}
