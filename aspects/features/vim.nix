{ lib, ... }:
{
  flake.modules.homeManager.vim = { config, ... }: {
    home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink ../../modules/home/vim/vimrc;
  };
}
