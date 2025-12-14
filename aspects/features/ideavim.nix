{ lib, ... }:
{
  flake.homeManagerModules.ideavim = { ... }: {
    home.file.".ideavimrc".source = ../../modules/home/ideavim/ideavimrc;
  };
}
