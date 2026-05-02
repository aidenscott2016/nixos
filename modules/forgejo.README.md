# Forgejo bootstrap

The Nix module declares the service, OIDC auth source registration, and
runner. These steps are imperative and must be run once after a clean
provision of bes.

## 1. OIDC client secret (before first deploy)

Generate a random plaintext, then hash it with authelia. Both pieces are
needed:

    PLAINTEXT=$(head -c 48 /dev/urandom | base64 | tr -d '/+=' | cut -c1-64)
    nix run nixpkgs#authelia -- crypto hash generate pbkdf2 \
      --variant sha512 --password "$PLAINTEXT"

- The printed `Digest:` value (`$pbkdf2-sha512$...`) goes into
  `identity_providers.oidc.clients.<forgejo>.client_secret` in
  `modules/authelia.nix`.
- The plaintext is stored in `secrets/forgejo-oidc-client-secret.age`
  (see `secrets/secrets.nix` for the recipient list). Encrypt with:

      EDITOR='tee' agenix --edit secrets/forgejo-oidc-client-secret.age
      # paste the plaintext, then Ctrl-D

  Or use the non-interactive editor wrapper trick if scripting it.

## 2. First admin user (after first deploy, on bes)

Registration is disabled and OIDC auto-creation runs only on first
sign-in. Create a local admin via the CLI so the OIDC source can be
linked:

    sudo -u git forgejo \
      --config /var/lib/forgejo/custom/conf/app.ini \
      admin user create \
      --username aiden --email git@oldstreetjournal.co.uk \
      --random-password --admin

Sign in once with the printed random password, then sign out and sign in
again via "Sign in with Authelia". `oauth2_client.ACCOUNT_LINKING =
"login"` merges the two accounts by email, provided the email matches
the one in `secrets/authelia-users.age`.

## 3. Runner registration token (after first deploy)

In Forgejo: Site Administration -> Actions -> Runners -> "Create new
Runner". Copy the token.

The runner's `tokenFile` is consumed as a systemd `EnvironmentFile`, so
the secret must contain a `TOKEN=...` line (not just the raw token):

    echo "TOKEN=<paste-token-here>" | EDITOR='tee' agenix --edit \
      secrets/forgejo-runner-token.age

Then enable the `services.gitea-actions-runner.instances.bes` block in
`modules/forgejo.nix`, declare `age.secrets.forgejo-runner-token`, and
redeploy.
