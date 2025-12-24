{
  aiden.syncthing.nixos = {
    services.syncthing = {
      enable = true;
      user = "aiden";
      dataDir = "/home/aiden/.syncthing";
      configDir = "/home/aiden/.config/syncthing";
    };
  };
}
