params@{ pkgs, lib, config, ... }:
with lib.aiden;
{
  options.aiden.modules.common = with lib; {
    enabled = mkEnableOption "";
    domainName = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
  };

  config = {
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.auto-optimise-store = true;
    nix.settings.trusted-users = [ "aiden" ];

    users.users.aiden = {
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" "disk" "networkmanager" "video" ];
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

    environment.systemPackages = with pkgs; [ vim ];

    programs.bash.shellInit = ''
      set -o vi
    '';
  };
}
