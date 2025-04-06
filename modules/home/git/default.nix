{ config, lib, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Aiden";
    userEmail = "aiden@oldstreetjournal.co.uk";
    extraConfig = {
      merge.conflictstyle = "zdiff3";
      pull.rebase = true;
      rerere.enabled = true;
      help.autocorrect = -1;
      core = { excludesfile = "${./gitignore}"; };
      push = {
        autoSetupRemote = true;
        default = "current";
      };
    };
  };
}
