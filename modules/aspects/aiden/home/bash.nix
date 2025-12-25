{ ... }:
{
  aiden.home.bash.nixos = {
    home-manager.users.aiden.programs.bash = {
      enable = true;
      bashrcExtra = ''
        set -o vi
      '';
    };
  };
}
