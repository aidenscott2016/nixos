{ config, pkgs, lib, ... }:

with lib;
{
  options = {
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = lib.mdDoc "The user's auxiliary groups.";
    };
  };
  config = {
    system.stateVersion = "22.05";
    nixpkgs.config.allowUnfree = true;
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.auto-optimise-store = true;

    users.groups.cheese = { };
    users.users.aiden = {
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" "disk" "docker" "cheese" ];
    };

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };
  };

}
