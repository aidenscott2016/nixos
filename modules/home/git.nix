{ config, lib, pkgs, ... }:
{
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
}
