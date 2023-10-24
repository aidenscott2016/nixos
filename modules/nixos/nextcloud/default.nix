{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.mine.nextcloud;
in
{
  # options.services.mine.nextcloud = {
  #   enable = mkEnableOption "nextcloud aiden";
  # };

  # config = mkIf cfg.enable {
  #   services.nextcloud = {
  #     enable = true;
  #     package = pkgs.nextcloud25;
  #     hostName = "localhost";
  #     config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}";
  #   };
  # };
}
