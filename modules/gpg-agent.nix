{ ... }:
{
  flake.modules.homeManager.gpg-agent =
    { pkgs, ... }:
    {
      services.gpg-agent = {
        enable = true;
        enableBashIntegration = true;
        grabKeyboardAndMouse = true;
        enableSshSupport = true;
        pinentry.package = pkgs.pinentry-gtk2;
      };
    };
}
