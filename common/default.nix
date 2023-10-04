{ config, pkgs, lib, ... }:

with lib; {
  config = {
    #system.stateVersion = "22.05";
    nixpkgs.config.allowUnfree = true;
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.auto-optimise-store = true;
    nix.settings.trusted-users = [ "aiden" ];

    users.groups.cheese = { };
    users.users.aiden = {
      initialPassword = "password";
      isNormalUser = true;
      extraGroups =
        [ "wheel" "disk" "docker" "cheese" "networkmanager" "video" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars"
      ];

    };

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };
    services.xserver = {
      layout = "gb";
      xkbOptions = "caps:swapescape";
      libinput.enable = true;
    };

    environment.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
