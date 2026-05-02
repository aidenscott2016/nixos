{ inputs, ... }:
{
  flake.modules.nixos.forgejo =
    { config, pkgs, lib, ... }:
    let
      cfg = config.services.forgejo;
      forgejoBin = lib.getExe cfg.package;
    in
    {
      services.forgejo = {
        enable = true;
        user = "git";
        group = "git";
        database.type = "sqlite3";
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "git.sw1a1aa.uk";
            ROOT_URL = "https://git.sw1a1aa.uk/";
            HTTP_ADDR = "127.0.0.1";
            # 3000 (paperless-ai), 3001 (uptime-kuma), 3005, 3100 are in use on bes.
            HTTP_PORT = 3002;
            START_SSH_SERVER = false;
            SSH_DOMAIN = "git.sw1a1aa.uk";
            SSH_PORT = 22;
            SSH_CREATE_AUTHORIZED_KEYS_FILE = true;
          };
          service = {
            DISABLE_REGISTRATION = true;
            ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
            REQUIRE_SIGNIN_VIEW = false;
          };
          openid.ENABLE_OPENID_SIGNIN = false;
          oauth2_client = {
            ENABLE_AUTO_REGISTRATION = true;
            USERNAME = "nickname";
            ACCOUNT_LINKING = "login";
            UPDATE_AVATAR = true;
          };
          actions.ENABLED = true;
          session.COOKIE_SECURE = true;
        };
      };

      # Forgejo only auto-creates users.users.forgejo when cfg.user == "forgejo".
      # We override cfg.user to "git" so clone URLs read git@git.sw1a1aa.uk:... and
      # so the system sshd serves git operations from ~git/.ssh/authorized_keys
      # (which is /var/lib/forgejo/.ssh/authorized_keys, written by Forgejo itself).
      users.users.git = {
        home = cfg.stateDir;
        useDefaultShell = true;
        group = "git";
        isSystemUser = true;
      };
      users.groups.git = { };

      age.secrets.forgejo-oidc-client-secret = {
        file = "${inputs.self.outPath}/secrets/forgejo-oidc-client-secret.age";
        owner = cfg.user;
        group = cfg.group;
        mode = "0400";
      };

      # Register Authelia as an OIDC auth source via the forgejo CLI on first
      # boot. Idempotent: the script checks for an existing entry named
      # "Authelia" before adding. Required because services.forgejo has no
      # high-level option for auth sources.
      systemd.services.forgejo-oidc-bootstrap = {
        description = "Register Authelia as a Forgejo OIDC auth source";
        after = [ "forgejo.service" "authelia-main.service" "traefik.service" ];
        wants = [ "forgejo.service" ];
        wantedBy = [ "multi-user.target" ];
        environment = {
          USER = cfg.user;
          HOME = cfg.stateDir;
          FORGEJO_WORK_DIR = cfg.stateDir;
          FORGEJO_CUSTOM = cfg.customDir;
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = cfg.user;
          Group = cfg.group;
          Restart = "on-failure";
          RestartSec = 30;
          LoadCredential = "client-secret:${config.age.secrets.forgejo-oidc-client-secret.path}";
        };
        script = ''
          set -eu
          if ${forgejoBin} admin auth list | ${pkgs.gawk}/bin/awk '{print $2}' | grep -qx Authelia; then
            echo "Authelia OIDC source already registered, skipping."
            exit 0
          fi
          SECRET=$(cat "$CREDENTIALS_DIRECTORY/client-secret")
          ${forgejoBin} admin auth add-oauth \
            --name Authelia \
            --provider openidConnect \
            --key forgejo \
            --secret "$SECRET" \
            --auto-discover-url https://auth.sw1a1aa.uk/.well-known/openid-configuration \
            --scopes "openid email profile groups" \
            --skip-local-2fa
        '';
      };

      aiden.modules.reverseProxy.apps = [
        { name = "git"; port = 3002; auth = false; }
      ];
    };
}
