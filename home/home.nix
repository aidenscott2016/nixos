{ config, pkgs, ... }:
{
  home.username = "aiden";
  home.homeDirectory = "/home/aiden";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Aiden";
    userEmail = "aiden@oldstreetjournal.co.uk";
    extraConfig = {
      pull.rebase = true;
      rerere.enabled = true;
      help.autocorrect = -1;
      core = {
        excludesfile = "${./files/gitignore}";
      };
      push = {
        autoSetupRemote = true;
        default = "current";
      };
    };
  };
  xdg.configFile."discord/settings.json".text = ''{"SKIP_HOST_UPDATE": true}'';
}

