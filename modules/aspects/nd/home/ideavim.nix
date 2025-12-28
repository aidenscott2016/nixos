{ nd, ... }: {
  nd.home.ideavim = {
    homeManager = { config, lib, pkgs, ... }: {
      home.file.".ideavimrc".source = ../../../_home/ideavim/ideavimrc;
    };
  };
}
