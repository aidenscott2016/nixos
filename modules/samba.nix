{ ... }:
{
  flake.modules.nixos.samba =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.modules.samba;
    in
    {
      options.aiden.modules.samba = {
        shares = mkOption {
          type = types.attrsOf (types.attrsOf types.unspecified);
          default = { };
        };
      };

      config.services = {
        samba = {
          package = pkgs.samba4Full;
          enable = true;
          openFirewall = true;
          shares = cfg.shares;
          settings = {
            global = {
              "server smb encrypt" = "required";
              "server min protocol" = "SMB3_00";
              "browseable" = "yes";
            };
          };
        };
        avahi = {
          publish.enable = true;
          publish.userServices = true;
          nssmdns4 = true;
          enable = true;
          openFirewall = true;
        };
        samba-wsdd = {
          enable = true;
          openFirewall = true;
        };
      };
    };
}
