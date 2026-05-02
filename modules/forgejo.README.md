# Forgejo bootstrap

The Nix module declares the service, OIDC auth source registration, and
runner. These steps are imperative and must be run once after a clean
provision of bes.

## Notes (declarative in `modules/forgejo.nix`)

- Forgejo listens on `127.0.0.1:3002` (Traefik `git` app). Ports 3000 and
  3001 on bes are commonly taken by other services; adjust if needed.
- `oauth2_client.ACCOUNT_LINKING = "auto"` links the Authelia identity to
  an existing Forgejo user by email without the `/user/link_account`
  confirmation screen. Use `"login"` instead if you want to confirm with
  local credentials first (use the **Sign in** tab on the link page, not
  Register).

## 1. OIDC client secret (before first deploy)

Generate a random plaintext, then hash it with authelia. Both pieces are
needed:

    PLAINTEXT=$(head -c 48 /dev/urandom | base64 | tr -d '/+=' | cut -c1-64)
    nix run nixpkgs#authelia -- crypto hash generate pbkdf2 \
      --variant sha512 --password "$PLAINTEXT"

- The printed `Digest:` value (`$pbkdf2-sha512$...`) goes into
  `identity_providers.oidc.clients.<forgejo>.client_secret` in
  `modules/authelia.nix`. The redirect URI must match Forgejo's OAuth
  name casing, e.g. `https://git.sw1a1aa.uk/user/oauth2/Authelia/callback`.
- The plaintext is stored in `secrets/forgejo-oidc-client-secret.age`
  (see `secrets/secrets.nix` for the recipient list). Encrypt with:

      EDITOR='tee' agenix --edit secrets/forgejo-oidc-client-secret.age
      # paste the plaintext, then Ctrl-D

  Or use the non-interactive editor wrapper trick if scripting it.

## 2. First admin user (after first deploy, on bes)

Registration is disabled. Create a local admin via the CLI (needed once
so the account exists before OIDC auto-linking):

    sudo -u git forgejo \
      --config /var/lib/forgejo/custom/conf/app.ini \
      admin user create \
      --username aiden --email git@oldstreetjournal.co.uk \
      --random-password --admin

With `ACCOUNT_LINKING = "auto"`, sign in via "Sign in with Authelia";
Forgejo merges by email if it matches `secrets/authelia-users.age`.

## 3. Runner registration token (after first deploy)

Either generate on bes (no UI):

    TOK=$(sudo -u git forgejo \
      --config /var/lib/forgejo/custom/conf/app.ini \
      actions generate-runner-token)
    printf 'TOKEN=%s\n' "$TOK" | EDITOR='tee' agenix --edit \
      secrets/forgejo-runner-token.age

Or in the web UI: Site Administration -> Actions -> Runners -> "Create
new Runner".

The runner's `tokenFile` is a systemd `EnvironmentFile`, so the secret
must contain a `TOKEN=...` line (not just the raw token). After updating
the `.age` file, redeploy bes.
