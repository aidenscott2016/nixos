params@{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.aiden.modules.common;
in
{
  options.aiden.modules.common = {
    enabled = mkEnableOption "";
    domainName = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
    publicKey = mkOption {
      type = types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars";
    };
  };
  config = mkIf cfg.enabled {
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.auto-optimise-store = true;
    nix.settings.trusted-users = [ "aiden" ];

    users.users.aiden = {
      uid = 1000;
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" "disk" "networkmanager" "video" ];
      openssh.authorizedKeys.keys = [ cfg.publicKey ];
    };
    users.groups.video.gid = 26;

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    services = {
      xserver = {
        xkb = {
          layout = "gb";
          options = "caps:swapescape";
        };
      };
    };

    environment.sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };

    environment.systemPackages = with pkgs; [ vim ];

    programs.bash.shellInit = ''
      set -o vi
    '';
  };
}

