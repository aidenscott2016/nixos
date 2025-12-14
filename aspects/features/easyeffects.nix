{ lib, ... }:
{
  flake.modules.homeManager.easyeffects = { ... }: {
    services.easyeffects = {
      enable = false;
      preset = "voice-chat";
    };
  };
}
