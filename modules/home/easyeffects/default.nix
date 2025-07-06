{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.easyeffects = {
    enable = false;
    preset = "voice-chat";
  };
}
