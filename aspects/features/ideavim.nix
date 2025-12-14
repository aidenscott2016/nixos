{ lib, ... }:
{
  flake.modules.homeManager.ideavim = { ... }: {
    home.file.".ideavimrc".source = ../../modules/home/ideavim/ideavimrc;
  };
}
