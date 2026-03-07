{ ... }:
{
  flake.modules.homeManager.vim =
    { config, lib, pkgs, ... }:
    {
      home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink ./vimrc;
    };
}
