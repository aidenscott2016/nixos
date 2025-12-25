{
  aiden.samba.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.samba or { };
    in
    {
      options.aiden.aspects.samba = {
        enable = mkEnableOption "Samba file sharing";
        shares = mkOption {
          type = types.attrsOf (types.attrsOf types.unspecified);
          default = { };
          description = "Samba share definitions";
        };
      };

      config = mkIf (cfg.enable or false) {
        services = {
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
    };
}
