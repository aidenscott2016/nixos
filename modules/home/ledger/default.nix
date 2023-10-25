inputs@{ config, pkgs, lib, ... }: {
  programs.ledger = {
    enable = true;
    package = pkgs.hledger;
  };
  home.sessionVariables = { LEDGER_FILE = "~/ledger/2023.journal"; };
}
