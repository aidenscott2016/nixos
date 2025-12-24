{
  aiden.emacs.nixos =
    { pkgs, ... }:
    {
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
}
