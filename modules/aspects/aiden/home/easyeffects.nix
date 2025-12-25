{ ... }:
{
  aiden.home.easyeffects.nixos = {
    home-manager.users.aiden.services.easyeffects = {
      enable = false;
      preset = "voice-chat";
    };
  };
}
