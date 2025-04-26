params@{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

with lib.aiden;
with pkgs;
let
  steamtinkerlaunch-git = pkgs.steamtinkerlaunch.overrideAttrs (_: {
    src = inputs.steamtinkerlaunch;
  });
in
enableableModule "steam" params {
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ steamtinkerlaunch-git ];
  };
  environment.systemPackages = [
    steamtinkerlaunch-git
  ];
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;
  programs.gamemode.settings = {
    general = {
      renice = 10;
    };

    # Warning: GPU optimisations have the potential to damage hardware
    gpu = {
      apply_gpu_optimisations = "accept-responsibility";
      gpu_device = 0;
      nv_powermizer_mode = 1;
    };

    custom = {
      start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
      end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
    };
  };
  users.users.aiden.extraGroups = [ "gamemode" ];
}
