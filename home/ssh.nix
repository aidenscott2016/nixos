{ config, lib, pkgs, ... }:

{

  programs.ssh.enable = true;
  programs.ssh.matchBlocks."gitlab.com".identityFile = "~/.ssh/gitlab";
  programs.ssh.matchBlocks."github.com".identityFile = "~/.ssh/github";
  programs.ssh.matchBlocks."10.0.4.*".identityFile = "~/.ssh/local";
}
