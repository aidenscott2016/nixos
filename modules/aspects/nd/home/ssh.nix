{ nd, ... }: {
  nd.home.ssh = {
    homeManager = { config, lib, pkgs, ... }: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "gitlab.com".identityFile = "~/.ssh/gitlab";
          "github.com".identityFile = "~/.ssh/github";
          "192.168.* 10.0.* *.local *.sw1a1aa.uk" = {
            forwardAgent = true;
            identityFile = "~/.ssh/local";
          };

          # virtual machines
          "192.168.122.*".extraOptions = {
            "StrictHostKeyChecking" = "no";
            "UserKnownHostsFile" = "/dev/null";
          };

          # Default configuration
          "*" = {
            compression = true;
            serverAliveInterval = 30;
            serverAliveCountMax = 3;
          };
        };
      };
    };
  };
}
