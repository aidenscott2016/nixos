inputs@{ ... }:
{
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
    pinentryFlavor = "gtk2";
  };
}
