{ ... }:
{
  flake.modules.homeManager.easyeffects =
    { config, lib, pkgs, ... }:
    {
      services.easyeffects = {
        enable = false;
        preset = "voice-chat";
      };
    };
}
