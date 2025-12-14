{ lib, ... }:
{
  flake.homeManagerModules.gpg-agent = { pkgs, ... }: {
    # programs.gnupg.agent = {
    #   enable = true;
    #   pinentryFlavor = "gtk2";
    #   enableSSHSupport = true;
    # };

    services.gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      grabKeyboardAndMouse = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gtk2;
    };
  };
}
