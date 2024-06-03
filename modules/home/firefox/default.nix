{ pkgs, inputs, ... }:
let addons = inputs.firefox-addons.packages.${pkgs.system};
in {
  home.file.".tridactylrc".source = ./tridactylrc;

  nixpkgs.config.firefox.speechSynthesisSupport = true;
  programs.firefox = {
    enable = true;
    profiles.aiden = {
      extensions = with addons; [
        sponsorblock
        tridactyl
        ublock-origin
        darkreader
      ];
      settings = {
        "privacy.resistFingerprinting" = false; # too annoying
        "browser.compactmode.show" = true;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "browser.uidensity" = 1;
        "browser.download.autohideButton" = false;
        "browser.uiCustomization.state" = ''

          {"placements":{"widget-overflow-fixed-list":["save-to-pocket-button"],"unified-extensions-area":[],"nav-bar":["back-button","forward-button","stop-reload-button","urlbar-container","downloads-button","fxa-toolbar-menu-button","sponsorblocker_ajay_app-browser-action","ublock0_raymondhill_net-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","sponsorblocker_ajay_app-browser-action","ublock0_raymondhill_net-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":3}

        '';
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.urlbar.suggest.topsites" = false;
        "extensions.pocket.enabled" = false;
      };
    };

  };
}

