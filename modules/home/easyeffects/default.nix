{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.easyeffects = {
    enable = true;
    preset = "voice-chat";
  };
}
