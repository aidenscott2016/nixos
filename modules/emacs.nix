{ ... }:
{
  flake.modules.nixos.emacs =
    { pkgs, lib, config, ... }:
    with pkgs;
    {
        environment.systemPackages =  [
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
}
