{
  config,
  lib,
  pkgs,
  ...
}:

{

  programs.ssh.enable = true;
  programs.ssh.matchBlocks."gitlab.com".identityFile = "~/.ssh/gitlab";
  programs.ssh.matchBlocks."github.com".identityFile = "~/.ssh/github";
  programs.ssh.matchBlocks."192.168.* 10.0.* *.local *.sw1a1aa.uk" = {
    forwardAgent = true;
    identityFile = "~/.ssh/local";
  };

  # virtual machines
  programs.ssh.matchBlocks."192.168.122.*".extraOptions = {
    "StrictHostKeyChecking" = "no";
    "UserKnownHostsFile" = "/dev/null";
  };

}
