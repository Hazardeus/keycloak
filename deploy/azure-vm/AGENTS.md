# AGENTS.md — deploy/azure-vm/

Instructions for AI coding agents (and humans) working inside this directory.

## Scope

This directory contains an **independent** Azure VM deployment of Keycloak for
AG-Flow. It is not a continuation, replacement, or refactor of the upstream
Proxmox/LXC deployment at the repository root — it is a separate deployment
target that happens to live in the same repo.

Everything Azure-specific must stay under `deploy/azure-vm/`. Do not introduce
Azure assumptions anywhere else in the repository.

## Hard boundaries — do not cross

- **Never modify** the repository root Proxmox/LXC files:
  - `01-create-lxc.sh`
  - `02-install-keycloak.sh`
  - `03-apply-realm.sh`
  - `yoops-realm.json`
  These belong to the upstream project (`gaelgael5/keycloak`) and must stay
  mergeable from upstream without conflicts caused by Azure work.
- **Never edit the root `CLAUDE.md`.** It documents Gaël's Proxmox/LXC
  operational setup and is out of scope for Azure work.
- **Never copy upstream-specific infrastructure assumptions into Azure code**,
  including but not limited to:
  - the host `root@192.168.10.90`
  - the SSH key `~/.ssh/id_shellia`
  - the realm name `yoops`
  - anything Proxmox- or LXC-specific
- Do not touch anything outside `deploy/azure-vm/` unless the user explicitly
  asks for it (e.g. a shared `.gitignore` entry for `deploy/azure-vm/.env`).

## Deployment model

- Docker Compose only, kept explicit and minimal — no unnecessary services,
  no orchestration frameworks, no magic.
- Keycloak realm for this deployment is **`agflow`** (not `yoops`).
- Keycloak uses a **dedicated PostgreSQL container/instance** created for this
  deployment. Never point Keycloak at the AG-Flow application's own Postgres
  instance — separate data, separate credentials, separate volume.
- Current scope is intentionally narrow. Only build/configure:
  - Keycloak
  - PostgreSQL (dedicated)
  - the `agflow` realm
  - a bootstrap admin account
  - backup scripts
- Explicitly out of scope for now (do not implement until asked):
  - Entra ID / any external identity provider federation
  - OIDC clients for Portal, Docflow, RAG, Harpocrate, or Workflow
- Network exposure during the lab/bootstrap phase:
  - Keycloak must bind only to `127.0.0.1` on the Azure VM — never `0.0.0.0`
    and never a public port mapping.
  - Initial (and current) access path is an SSH tunnel to the VM, not a public
    HTTPS endpoint, reverse proxy, or Cloudflare Tunnel.

## Secrets

- Never commit secrets, passwords, tokens, or realm exports containing
  credentials.
- `deploy/azure-vm/.env` is the local secrets file and must stay git-ignored.
  Verify it is covered by `.gitignore` before adding new env-consuming files.
- `deploy/azure-vm/.env.example` must only contain placeholder values.
- If a script generates credentials (bootstrap admin password, DB password,
  client secrets), write them to a local untracked file or stdout — never into
  a file that gets committed.

## Review checklist

Before considering any change in this directory done, check for:

1. **Secret leaks** — no real passwords/tokens/keys in tracked files.
2. **Accidental public port exposure** — no `0.0.0.0` binds, no Compose port
   mappings that expose Keycloak or Postgres beyond `127.0.0.1`.
3. **Modification of upstream Proxmox files** — the four root files above and
   root `CLAUDE.md` must be untouched.
4. **Invalid Keycloak environment variables** — cross-check against the
   Keycloak version in use (env var names/prefixes changed across major
   versions, e.g. `KC_BOOTSTRAP_ADMIN_*` vs legacy `KEYCLOAK_ADMIN*`).
5. **Unsafe Docker Compose settings** — avoid `privileged: true`, avoid
   mounting the Docker socket, avoid running as root inside containers when
   an official non-root image/user is available, pin image tags (no floating
   `latest` for reproducibility).
6. **Persistence and backup issues** — Postgres data must be on a named
   volume (or bind mount) that survives `docker compose down`; backup scripts
   must actually produce restorable dumps and must not silently fail.

## Compatibility with upstream

Because this repo tracks an upstream project, keep Azure work isolated so
future `git merge`/`git pull` from `gaelgael5/keycloak` stays conflict-free:
- Only add/modify files under `deploy/azure-vm/`.
- Do not rename or move root-level upstream files.
- Do not add Azure-related content to the root `README.md` unless explicitly
  asked; prefer `deploy/azure-vm/README.md`.

## Git hygiene

- Do not run `git commit` or `git push` unless explicitly requested by the
  user, even after finishing a task.
