{ ... }:
{
  flake.modules.nixos.ssh =
    { pkgs, lib, config, ... }:
    {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
      users.users.aiden.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCoq4Vfco724r3Ogg0s2fijnu9GtDsDW/e5JsKAQOzf"
      ];
    };

  flake.modules.homeManager.ssh =
    { config, pkgs, lib, ... }:
    {
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
          "192.168.122.*".extraOptions = {
            "StrictHostKeyChecking" = "no";
            "UserKnownHostsFile" = "/dev/null";
          };
          "*" = {
            compression = true;
            serverAliveInterval = 30;
            serverAliveCountMax = 3;
          };
        };
      };
    };
}
