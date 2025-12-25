{ ... }:
{
  aiden.home.gpg-agent.nixos = { pkgs, ... }: {
    home-manager.users.aiden.services.gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      grabKeyboardAndMouse = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gtk2;
    };
  };
}
