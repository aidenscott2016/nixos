{ ... }:
{
  aiden.home.git.nixos = {
    home-manager.users.aiden.programs.git = {
      enable = true;
      extraConfig = {
        user = {
          name = "Aiden";
          email = "aiden@oldstreetjournal.co.uk";
        };
        merge.conflictstyle = "zdiff3";
        pull.rebase = true;
        rerere.enabled = true;
        help.autocorrect = -1;
        core = {
          excludesfile = "${./git/gitignore}";
        };
        push = {
          autoSetupRemote = true;
          default = "current";
        };
      };
    };
  };
}
