{ nd, ... }: {
  nd.home.easyeffects = {
    homeManager = { config, lib, pkgs, ... }: {
      services.easyeffects = {
        enable = false;
        preset = "voice-chat";
      };
    };
  };
}
