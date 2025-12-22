{ lib, ... }:
{
  flake.modules.homeManager.git = { ... }: {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Aiden";
          email = "aiden@oldstreetjournal.co.uk";
        };
        merge.conflictstyle = "zdiff3";
        pull.rebase = true;
        rerere.enabled = true;
        help.autocorrect = -1;
        core = {
          excludesfile = "${./gitignore}";
        };
        push = {
          autoSetupRemote = true;
          default = "current";
        };
      };
    };
  };
}
