{ nd, ... }: {
  nd.avahi = {
    nixos = {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
        openFirewall = true;
      };
    };
  };
}
