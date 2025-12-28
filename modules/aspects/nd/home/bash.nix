{ nd, ... }: {
  nd.home.bash = {
    homeManager = { config, pkgs, ... }: {
      programs.bash = {
        enable = true;
        bashrcExtra = ''
          set -o vi
        '';
      };
    };
  };
}
