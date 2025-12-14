{ lib, ... }:
{
  flake.homeManagerModules.easyeffects = { ... }: {
    services.easyeffects = {
      enable = false;
      preset = "voice-chat";
    };
  };
}
