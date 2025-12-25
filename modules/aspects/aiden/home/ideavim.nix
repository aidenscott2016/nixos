{ ... }:
{
  aiden.home.ideavim.nixos = {
    home-manager.users.aiden.home.file.".ideavimrc".source = ./ideavim/ideavimrc;
  };
}
