{ lib, ... }:
{
  flake.nixosModules.emacs = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.emacs;
    in {
      options.aiden.modules.emacs.enable = mkEnableOption "emacs";

      config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          coreutils
          fd
          clang
          nixfmt-rfc-style
          emacs
          racket
          ripgrep
          nixpkgs-fmt
          nodePackages.prettier
          nixd
          nil
        ];
      };
    };
}
