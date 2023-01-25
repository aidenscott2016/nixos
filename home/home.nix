inputs@{ config, pkgs, lib, ... }:
{
  imports = [
    ./git.nix
    ./tmux
    ./bash
    ./firefox
  ];
  home.stateVersion = "23.05";

  xdg.configFile."discord/settings.json".text = ''{"SKIP_HOST_UPDATE": true}'';
  xdg.configFile."emacs/init.el".source = ./files/init.el;
  xdg.enable = true;

  programs.ssh.enable = true;
  programs.ssh.matchBlocks."gitlab.com".identityFile = "~/.ssh/gitlab";
  programs.ssh.matchBlocks."10.0.4.*".identityFile = "~/.ssh/local";

  # programs.librewolf = {
  #   enable = true;
  #   settings = {
  #     "browser.compactmode.show" = true;
  #     "privacy.clearOnShutdown.history" = false;
  #     "privacy.clearOnShutdown.cookies" = false;
  #     "browser.uidensity" = 1;
  #   };
  # };
}
