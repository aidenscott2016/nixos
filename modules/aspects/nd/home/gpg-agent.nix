{ nd, ... }: {
  nd.home.gpg-agent = {
    homeManager = { pkgs, ... }: {
      services.gpg-agent = {
        enable = true;
        enableBashIntegration = true;
        grabKeyboardAndMouse = true;
        enableSshSupport = true;
        pinentryPackage = pkgs.pinentry-gtk2;
      };
    };
  };
}
