# `create-oidc-client.sh` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement `scripts/create-oidc-client.sh`, a standalone bash tool that creates an OIDC client on a remote Keycloak via the admin REST API, authenticated by the `ag-flow-provisioner` service account.

**Architecture:** Single bash script with library-style internal functions (sourceable for unit tests). Pure functions (arg parsing, validation, JSON payload building, webOrigins derivation) are unit-tested with `bats-core`. HTTP-touching functions are integration-tested against a local Python `http.server` mock that mimics the relevant Keycloak admin endpoints. End-to-end smoke test against the same mock validates the full happy path.

**Tech Stack:** bash 4+, curl, jq, bats-core (tests), python3 (mock server). No external libraries beyond what's standard on a dev Linux/WSL host.

**Spec:** `docs/superpowers/specs/2026-05-20-keycloak-create-oidc-client-design.md`

## File Structure

| Path | Purpose | Created/Modified |
|---|---|---|
| `scripts/create-oidc-client.sh` | The script itself (library + CLI entrypoint, sourceable) | Create |
| `tests/create-oidc-client/test_pure.bats` | Unit tests for pure functions (parse, validate, build_payload, derive_web_origins) | Create |
| `tests/create-oidc-client/test_http.bats` | Integration tests against mock Keycloak | Create |
| `tests/create-oidc-client/mock-keycloak.py` | Python mock that responds like Keycloak admin API | Create |
| `tests/create-oidc-client/helpers.bash` | Shared bats helpers (start/stop mock, fixtures) | Create |

The script is structured as a set of small functions with a single `main` at the bottom, gated by `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`. This lets bats source the script and call individual functions without executing `main`.

---

## Task 1: Script skeleton with `--help` and `-h`

**Files:**
- Create: `scripts/create-oidc-client.sh`
- Create: `tests/create-oidc-client/test_pure.bats`
- Create: `tests/create-oidc-client/helpers.bash`

- [ ] **Step 1: Verify `bats-core` is installed**

Run: `bats --version`
Expected: `Bats X.Y.Z`. If missing, install (Debian/Ubuntu/WSL: `sudo apt install -y bats`).

- [ ] **Step 2: Write the failing test for `--help`**

Create `tests/create-oidc-client/helpers.bash`:
```bash
SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../scripts/create-oidc-client.sh"

source_script() {
  # Source the script in library mode (main not invoked).
  # shellcheck disable=SC1090
  source "${SCRIPT_PATH}"
}
```

Create `tests/create-oidc-client/test_pure.bats`:
```bash
#!/usr/bin/env bats

load helpers

@test "--help exits 0 and prints usage" {
  run bash "${SCRIPT_PATH}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"create-oidc-client.sh"* ]]
  [[ "$output" == *"--url"* ]]
  [[ "$output" == *"--client-id"* ]]
  [[ "$output" == *"--type"* ]]
}

@test "-h is equivalent to --help" {
  run bash "${SCRIPT_PATH}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "no args prints usage to stderr and exits 1" {
  run bash "${SCRIPT_PATH}"
  [ "$status" -eq 1 ]
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: 3 failures — script doesn't exist yet.

- [ ] **Step 4: Write the minimal script**

Create `scripts/create-oidc-client.sh`:
```bash
#!/usr/bin/env bash
#
# create-oidc-client.sh
# Crée un client OIDC sur un Keycloak distant via l'API admin REST,
# authentifié par un service account (par défaut ag-flow-provisioner).
#
# Spec: docs/superpowers/specs/2026-05-20-keycloak-create-oidc-client-design.md
#
set -euo pipefail

# ----- Logging (stderr) ------------------------------------------------------

log()   { printf '==> %s\n'   "$*" >&2; }
warn()  { printf 'WARN: %s\n' "$*" >&2; }
err()   { printf 'ERR:  %s\n' "$*" >&2; }

# ----- Usage -----------------------------------------------------------------

usage() {
  cat <<'EOF'
Usage:
  create-oidc-client.sh --url <KC_URL> --client-id <id> --type <type> [options]

Obligatoire:
  --url <URL>          URL ou IP du Keycloak (sans trailing slash)
  --client-id <id>     clientId du nouveau client
  --type <type>        public | confidential | bearer-only | service-account

Optionnel:
  --realm <name>       Realm cible (défaut: yoops)
  --name <text>        displayName du client
  --description <text> description
  --redirect-uri <uri> Répétable. Requis pour public/confidential.
  --web-origin <orig>  Répétable. Pour public (sinon dérivé).
  --base-url <url>     baseUrl du client
  -h, --help           Cette aide

Variables d'environnement (auth):
  KC_SA_CLIENT_ID      Défaut: ag-flow-provisioner
  KC_SA_CLIENT_SECRET  Obligatoire
  KC_SA_REALM          Défaut: yoops

Output:
  stdout  JSON {realm, clientId, type, secret, issuer, well_known}
  stderr  Progression et erreurs

Exit codes:
  0  Succès
  1  Erreur d'usage / précondition
  2  Erreur API Keycloak
EOF
}

# ----- main ------------------------------------------------------------------

main() {
  if [[ $# -eq 0 ]]; then
    usage >&2
    exit 1
  fi
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
  esac
  # Le reste sera implémenté dans les tasks suivantes.
  err "not implemented yet"
  exit 1
}

# ----- entry point -----------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

- [ ] **Step 5: Make the script executable**

Run: `chmod +x scripts/create-oidc-client.sh`

- [ ] **Step 6: Run tests to verify they pass**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: 3 passes.

- [ ] **Step 7: Commit**

```bash
git add scripts/create-oidc-client.sh tests/create-oidc-client/test_pure.bats tests/create-oidc-client/helpers.bash
git commit -m "feat(scripts): bootstrap create-oidc-client.sh with --help"
```

---

## Task 2: Parse CLI arguments

**Files:**
- Modify: `scripts/create-oidc-client.sh` (add `parse_args` function)
- Modify: `tests/create-oidc-client/test_pure.bats`

- [ ] **Step 1: Write failing tests for `parse_args`**

Append to `tests/create-oidc-client/test_pure.bats`:
```bash
@test "parse_args: all required flags populate variables" {
  source_script
  parse_args --url https://kc.example.org --client-id myapp --type public
  [ "$ARG_URL" = "https://kc.example.org" ]
  [ "$ARG_CLIENT_ID" = "myapp" ]
  [ "$ARG_TYPE" = "public" ]
}

@test "parse_args: --realm defaults to yoops when absent" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only
  [ "$ARG_REALM" = "yoops" ]
}

@test "parse_args: --realm overrides default" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only --realm staging
  [ "$ARG_REALM" = "staging" ]
}

@test "parse_args: --redirect-uri is repeatable" {
  source_script
  parse_args --url https://kc --client-id x --type public \
    --redirect-uri 'https://a/*' --redirect-uri 'http://b:5173/*'
  [ "${#ARG_REDIRECT_URIS[@]}" -eq 2 ]
  [ "${ARG_REDIRECT_URIS[0]}" = "https://a/*" ]
  [ "${ARG_REDIRECT_URIS[1]}" = "http://b:5173/*" ]
}

@test "parse_args: --web-origin is repeatable" {
  source_script
  parse_args --url https://kc --client-id x --type public \
    --web-origin 'https://a' --web-origin 'http://b:5173'
  [ "${#ARG_WEB_ORIGINS[@]}" -eq 2 ]
}

@test "parse_args: optional text flags populate" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only \
    --name 'Mon App' --description 'desc' --base-url 'https://app'
  [ "$ARG_NAME" = "Mon App" ]
  [ "$ARG_DESCRIPTION" = "desc" ]
  [ "$ARG_BASE_URL" = "https://app" ]
}

@test "parse_args: unknown flag exits 1" {
  run bash "${SCRIPT_PATH}" --url https://kc --client-id x --type public --bogus
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"unknown"* ]] || [[ "$output" == *"unknown"* ]]
}
```

Note: bats `run` merges stderr into `$output` unless `--separate-stderr` is used. The OR keeps the check simple.

- [ ] **Step 2: Run tests to verify they fail**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: 7 failures (`parse_args` undefined).

- [ ] **Step 3: Implement `parse_args`**

In `scripts/create-oidc-client.sh`, insert before `main()`:
```bash
# ----- Arg parsing -----------------------------------------------------------

# Globals populated by parse_args. Declared with defaults so the script
# can be sourced in tests without `set -u` exploding on unset reads.
ARG_URL=""
ARG_CLIENT_ID=""
ARG_TYPE=""
ARG_REALM="yoops"
ARG_NAME=""
ARG_DESCRIPTION=""
ARG_BASE_URL=""
ARG_REDIRECT_URIS=()
ARG_WEB_ORIGINS=()

parse_args() {
  # Reset arrays so repeated sourcing in tests doesn't accumulate state.
  ARG_REDIRECT_URIS=()
  ARG_WEB_ORIGINS=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --url)           ARG_URL="$2";          shift 2 ;;
      --client-id)     ARG_CLIENT_ID="$2";    shift 2 ;;
      --type)          ARG_TYPE="$2";         shift 2 ;;
      --realm)         ARG_REALM="$2";        shift 2 ;;
      --name)          ARG_NAME="$2";         shift 2 ;;
      --description)   ARG_DESCRIPTION="$2";  shift 2 ;;
      --base-url)      ARG_BASE_URL="$2";     shift 2 ;;
      --redirect-uri)  ARG_REDIRECT_URIS+=("$2"); shift 2 ;;
      --web-origin)    ARG_WEB_ORIGINS+=("$2");   shift 2 ;;
      -h|--help)       usage; exit 0 ;;
      *)               err "unknown flag: $1"; usage >&2; exit 1 ;;
    esac
  done
}
```

Update `main()`:
```bash
main() {
  if [[ $# -eq 0 ]]; then
    usage >&2
    exit 1
  fi
  parse_args "$@"
  err "not implemented yet"
  exit 1
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: all 10 tests pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/create-oidc-client.sh tests/create-oidc-client/test_pure.bats
git commit -m "feat(scripts): parse CLI args for create-oidc-client.sh"
```

---

## Task 3: Validate arguments

**Files:**
- Modify: `scripts/create-oidc-client.sh` (add `validate_args` function)
- Modify: `tests/create-oidc-client/test_pure.bats`

- [ ] **Step 1: Write failing tests for `validate_args`**

Append to `tests/create-oidc-client/test_pure.bats`:
```bash
@test "validate_args: missing --url fails" {
  source_script
  parse_args --client-id x --type bearer-only
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -ne 0 ]
  [[ "$output" == *"--url"* ]]
}

@test "validate_args: missing --client-id fails" {
  source_script
  parse_args --url https://kc --type bearer-only
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -ne 0 ]
}

@test "validate_args: invalid --type fails" {
  source_script
  parse_args --url https://kc --client-id x --type bogus
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -ne 0 ]
  [[ "$output" == *"type invalide"* ]] || [[ "$output" == *"invalid type"* ]]
}

@test "validate_args: missing KC_SA_CLIENT_SECRET fails" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only
  unset KC_SA_CLIENT_SECRET
  run validate_args
  [ "$status" -ne 0 ]
  [[ "$output" == *"KC_SA_CLIENT_SECRET"* ]]
}

@test "validate_args: public without --redirect-uri fails" {
  source_script
  parse_args --url https://kc --client-id x --type public
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -ne 0 ]
  [[ "$output" == *"redirect-uri"* ]]
}

@test "validate_args: confidential without --redirect-uri fails" {
  source_script
  parse_args --url https://kc --client-id x --type confidential
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -ne 0 ]
}

@test "validate_args: bearer-only with --redirect-uri fails" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only \
    --redirect-uri 'https://x/*'
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -ne 0 ]
  [[ "$output" == *"redirect-uri"* ]]
}

@test "validate_args: service-account with --redirect-uri fails" {
  source_script
  parse_args --url https://kc --client-id x --type service-account \
    --redirect-uri 'https://x/*'
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -ne 0 ]
}

@test "validate_args: valid public passes silently" {
  source_script
  parse_args --url https://kc --client-id x --type public \
    --redirect-uri 'https://x/*'
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -eq 0 ]
}

@test "validate_args: valid bearer-only passes silently" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only
  KC_SA_CLIENT_SECRET=s run validate_args
  [ "$status" -eq 0 ]
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: 10 new failures.

- [ ] **Step 3: Implement `validate_args`**

In `scripts/create-oidc-client.sh`, insert after `parse_args`:
```bash
# ----- Arg validation --------------------------------------------------------

validate_args() {
  [[ -n "$ARG_URL" ]]       || { err "--url est requis"; return 1; }
  [[ -n "$ARG_CLIENT_ID" ]] || { err "--client-id est requis"; return 1; }
  [[ -n "$ARG_TYPE" ]]      || { err "--type est requis"; return 1; }

  case "$ARG_TYPE" in
    public|confidential|bearer-only|service-account) ;;
    *) err "type invalide: $ARG_TYPE (attendu: public|confidential|bearer-only|service-account)"; return 1 ;;
  esac

  [[ -n "${KC_SA_CLIENT_SECRET:-}" ]] || {
    err "KC_SA_CLIENT_SECRET non défini (export KC_SA_CLIENT_SECRET=...)"
    return 1
  }

  case "$ARG_TYPE" in
    public|confidential)
      [[ "${#ARG_REDIRECT_URIS[@]}" -gt 0 ]] || {
        err "au moins un --redirect-uri est requis pour --type=$ARG_TYPE"
        return 1
      }
      ;;
    bearer-only|service-account)
      [[ "${#ARG_REDIRECT_URIS[@]}" -eq 0 ]] || {
        err "--redirect-uri n'est pas valide pour --type=$ARG_TYPE"
        return 1
      }
      [[ "${#ARG_WEB_ORIGINS[@]}" -eq 0 ]] || {
        err "--web-origin n'est pas valide pour --type=$ARG_TYPE"
        return 1
      }
      ;;
  esac
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: all 20 tests pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/create-oidc-client.sh tests/create-oidc-client/test_pure.bats
git commit -m "feat(scripts): validate args for create-oidc-client.sh"
```

---

## Task 4: Build JSON payload + derive webOrigins

**Files:**
- Modify: `scripts/create-oidc-client.sh` (add `derive_web_origins`, `build_payload`)
- Modify: `tests/create-oidc-client/test_pure.bats`

- [ ] **Step 1: Write failing tests for `derive_web_origins`**

Append to `tests/create-oidc-client/test_pure.bats`:
```bash
@test "derive_web_origins: https URI with path becomes scheme+host" {
  source_script
  result=$(derive_web_origins 'https://app.example.org/*')
  [ "$result" = "https://app.example.org" ]
}

@test "derive_web_origins: http URI with port preserves port" {
  source_script
  result=$(derive_web_origins 'http://localhost:5173/*')
  [ "$result" = "http://localhost:5173" ]
}

@test "derive_web_origins: multiple URIs produce deduped origins, one per line" {
  source_script
  result=$(derive_web_origins 'https://a/*' 'https://a/api/*' 'http://b:8080/*')
  # Expect 2 unique origins, order preserved
  [ "$(printf '%s\n' "$result" | wc -l)" -eq 2 ]
  [[ "$result" == *"https://a"* ]]
  [[ "$result" == *"http://b:8080"* ]]
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: 3 new failures.

- [ ] **Step 3: Implement `derive_web_origins`**

Insert in `scripts/create-oidc-client.sh` after `validate_args`:
```bash
# ----- Payload helpers -------------------------------------------------------

# Pour chaque redirectUri donné, extrait "scheme://host[:port]". Déduplique
# en préservant l'ordre. Émet une origine par ligne sur stdout.
derive_web_origins() {
  local uri origin
  declare -A seen=()
  local order=()
  for uri in "$@"; do
    if [[ "$uri" =~ ^([a-z]+://[^/]+) ]]; then
      origin="${BASH_REMATCH[1]}"
      if [[ -z "${seen[$origin]:-}" ]]; then
        seen[$origin]=1
        order+=("$origin")
      fi
    fi
  done
  printf '%s\n' "${order[@]}"
}
```

- [ ] **Step 4: Run tests to verify `derive_web_origins` passes**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: 23/23 pass.

- [ ] **Step 5: Write failing tests for `build_payload`**

Append to `tests/create-oidc-client/test_pure.bats`:
```bash
@test "build_payload: public has publicClient=true and standardFlow=true with PKCE" {
  source_script
  parse_args --url https://kc --client-id myapp --type public \
    --redirect-uri 'https://app/*'
  json=$(build_payload)
  [ "$(jq -r '.clientId' <<<"$json")" = "myapp" ]
  [ "$(jq -r '.protocol' <<<"$json")" = "openid-connect" ]
  [ "$(jq -r '.publicClient' <<<"$json")" = "true" ]
  [ "$(jq -r '.standardFlowEnabled' <<<"$json")" = "true" ]
  [ "$(jq -r '.directAccessGrantsEnabled' <<<"$json")" = "false" ]
  [ "$(jq -r '.implicitFlowEnabled' <<<"$json")" = "false" ]
  [ "$(jq -r '.bearerOnly' <<<"$json")" = "false" ]
  [ "$(jq -r '.serviceAccountsEnabled' <<<"$json")" = "false" ]
  [ "$(jq -r '.attributes["pkce.code.challenge.method"]' <<<"$json")" = "S256" ]
  [ "$(jq -r '.redirectUris | length' <<<"$json")" -eq 1 ]
  [ "$(jq -r '.redirectUris[0]' <<<"$json")" = "https://app/*" ]
  [ "$(jq -r '.webOrigins | length' <<<"$json")" -eq 1 ]
  [ "$(jq -r '.webOrigins[0]' <<<"$json")" = "https://app" ]
}

@test "build_payload: confidential has publicClient=false, no PKCE, redirectUris from flags" {
  source_script
  parse_args --url https://kc --client-id back --type confidential \
    --redirect-uri 'https://api/cb'
  json=$(build_payload)
  [ "$(jq -r '.publicClient' <<<"$json")" = "false" ]
  [ "$(jq -r '.standardFlowEnabled' <<<"$json")" = "true" ]
  [ "$(jq -r '.bearerOnly' <<<"$json")" = "false" ]
  [ "$(jq -r '.serviceAccountsEnabled' <<<"$json")" = "false" ]
  [ "$(jq -e '.attributes // {} | has("pkce.code.challenge.method") | not' <<<"$json")" ]
  [ "$(jq -r '.redirectUris[0]' <<<"$json")" = "https://api/cb" ]
}

@test "build_payload: bearer-only flags + no redirectUris" {
  source_script
  parse_args --url https://kc --client-id api --type bearer-only
  json=$(build_payload)
  [ "$(jq -r '.publicClient' <<<"$json")" = "false" ]
  [ "$(jq -r '.bearerOnly' <<<"$json")" = "true" ]
  [ "$(jq -r '.standardFlowEnabled' <<<"$json")" = "false" ]
  [ "$(jq -r '.directAccessGrantsEnabled' <<<"$json")" = "false" ]
  [ "$(jq -e '.redirectUris // [] | length == 0' <<<"$json")" ]
  [ "$(jq -e '.webOrigins // [] | length == 0' <<<"$json")" ]
}

@test "build_payload: service-account flags + no redirectUris" {
  source_script
  parse_args --url https://kc --client-id m2m --type service-account
  json=$(build_payload)
  [ "$(jq -r '.publicClient' <<<"$json")" = "false" ]
  [ "$(jq -r '.serviceAccountsEnabled' <<<"$json")" = "true" ]
  [ "$(jq -r '.standardFlowEnabled' <<<"$json")" = "false" ]
  [ "$(jq -r '.bearerOnly' <<<"$json")" = "false" ]
  [ "$(jq -e '.redirectUris // [] | length == 0' <<<"$json")" ]
}

@test "build_payload: public derives webOrigins from redirectUris if --web-origin absent" {
  source_script
  parse_args --url https://kc --client-id spa --type public \
    --redirect-uri 'https://a.org/*' \
    --redirect-uri 'http://localhost:5173/*'
  json=$(build_payload)
  origins=$(jq -r '.webOrigins | sort | .[]' <<<"$json")
  [[ "$origins" == *"https://a.org"* ]]
  [[ "$origins" == *"http://localhost:5173"* ]]
  [ "$(jq -r '.webOrigins | length' <<<"$json")" -eq 2 ]
}

@test "build_payload: public uses explicit --web-origin when provided (no derivation)" {
  source_script
  parse_args --url https://kc --client-id spa --type public \
    --redirect-uri 'https://a.org/*' \
    --web-origin '+'
  json=$(build_payload)
  [ "$(jq -r '.webOrigins[0]' <<<"$json")" = "+" ]
  [ "$(jq -r '.webOrigins | length' <<<"$json")" -eq 1 ]
}

@test "build_payload: --name --description --base-url are included when set" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only \
    --name 'Mon API' --description 'desc' --base-url 'https://app'
  json=$(build_payload)
  [ "$(jq -r '.name' <<<"$json")" = "Mon API" ]
  [ "$(jq -r '.description' <<<"$json")" = "desc" ]
  [ "$(jq -r '.baseUrl' <<<"$json")" = "https://app" ]
}

@test "build_payload: --name --description --base-url are omitted when empty" {
  source_script
  parse_args --url https://kc --client-id x --type bearer-only
  json=$(build_payload)
  [ "$(jq -e '. | has("name") | not' <<<"$json")" ]
  [ "$(jq -e '. | has("description") | not' <<<"$json")" ]
  [ "$(jq -e '. | has("baseUrl") | not' <<<"$json")" ]
}
```

- [ ] **Step 6: Run tests to verify `build_payload` tests fail**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: 8 new failures.

- [ ] **Step 7: Implement `build_payload`**

Insert in `scripts/create-oidc-client.sh` after `derive_web_origins`:
```bash
# Émet le JSON du payload de création de client sur stdout.
# Lit les ARG_* peuplés par parse_args.
build_payload() {
  local public_client="false" standard_flow="false" bearer_only="false" sa_enabled="false"
  local include_pkce="false"
  local -a redirect_uris=() web_origins=()

  case "$ARG_TYPE" in
    public)
      public_client="true"; standard_flow="true"; include_pkce="true"
      redirect_uris=("${ARG_REDIRECT_URIS[@]}")
      if [[ "${#ARG_WEB_ORIGINS[@]}" -gt 0 ]]; then
        web_origins=("${ARG_WEB_ORIGINS[@]}")
      else
        # Dérivation depuis redirectUris.
        local derived
        derived=$(derive_web_origins "${ARG_REDIRECT_URIS[@]}")
        while IFS= read -r origin; do
          [[ -n "$origin" ]] && web_origins+=("$origin")
        done <<<"$derived"
      fi
      ;;
    confidential)
      standard_flow="true"
      redirect_uris=("${ARG_REDIRECT_URIS[@]}")
      if [[ "${#ARG_WEB_ORIGINS[@]}" -gt 0 ]]; then
        web_origins=("${ARG_WEB_ORIGINS[@]}")
      fi
      ;;
    bearer-only)
      bearer_only="true"
      ;;
    service-account)
      sa_enabled="true"
      ;;
  esac

  # Construction du JSON via jq pour garantir l'échappement correct.
  local jq_args=(
    --arg clientId "$ARG_CLIENT_ID"
    --argjson publicClient "$public_client"
    --argjson standardFlow "$standard_flow"
    --argjson bearerOnly "$bearer_only"
    --argjson serviceAccountsEnabled "$sa_enabled"
    --argjson includePkce "$include_pkce"
  )

  # Tableaux pour redirectUris et webOrigins.
  local redirect_json='[]' web_origins_json='[]'
  if [[ "${#redirect_uris[@]}" -gt 0 ]]; then
    redirect_json=$(printf '%s\n' "${redirect_uris[@]}" | jq -R . | jq -s .)
  fi
  if [[ "${#web_origins[@]}" -gt 0 ]]; then
    web_origins_json=$(printf '%s\n' "${web_origins[@]}" | jq -R . | jq -s .)
  fi
  jq_args+=( --argjson redirectUris "$redirect_json" )
  jq_args+=( --argjson webOrigins   "$web_origins_json" )

  # Champs optionnels (omis si vides).
  jq_args+=( --arg name "$ARG_NAME" --arg description "$ARG_DESCRIPTION" --arg baseUrl "$ARG_BASE_URL" )

  jq -n "${jq_args[@]}" '
    {
      clientId: $clientId,
      protocol: "openid-connect",
      enabled: true,
      publicClient: $publicClient,
      standardFlowEnabled: $standardFlow,
      implicitFlowEnabled: false,
      directAccessGrantsEnabled: false,
      serviceAccountsEnabled: $serviceAccountsEnabled,
      bearerOnly: $bearerOnly
    }
    + (if ($redirectUris | length) > 0 then {redirectUris: $redirectUris} else {} end)
    + (if ($webOrigins   | length) > 0 then {webOrigins:   $webOrigins}   else {} end)
    + (if $includePkce then {attributes: {"pkce.code.challenge.method": "S256"}} else {} end)
    + (if $name        != "" then {name:        $name}        else {} end)
    + (if $description != "" then {description: $description} else {} end)
    + (if $baseUrl     != "" then {baseUrl:     $baseUrl}     else {} end)
  '
}
```

- [ ] **Step 8: Run tests to verify they pass**

Run: `bats tests/create-oidc-client/test_pure.bats`
Expected: all 31 tests pass.

- [ ] **Step 9: Commit**

```bash
git add scripts/create-oidc-client.sh tests/create-oidc-client/test_pure.bats
git commit -m "feat(scripts): build OIDC client payload by type"
```

---

## Task 5: Mock Keycloak HTTP server

**Files:**
- Create: `tests/create-oidc-client/mock-keycloak.py`

This mock simulates 5 endpoints of the Keycloak admin API, just enough for the integration tests:

| Method | Path | Behavior |
|---|---|---|
| `POST` | `/realms/{realm}/protocol/openid-connect/token` | Returns `{"access_token":"FAKE","expires_in":60}` if form has `client_id` + `client_secret` matching env `MOCK_SA_ID`/`MOCK_SA_SECRET`, else 401 |
| `GET` | `/admin/realms/{realm}/clients?clientId={id}` | Returns `[]` unless the in-memory store has `id`, then returns `[{"id":"uuid-<id>","clientId":"<id>"}]` |
| `POST` | `/admin/realms/{realm}/clients` | If body's `clientId` already in store → 409. Else stores it, returns 201 |
| `GET` | `/admin/realms/{realm}/clients/{uuid}/client-secret` | Returns `{"value":"secret-<uuid>"}` if `uuid` corresponds to a stored client, else 404 |
| `POST` | `/__reset` | Test-only: clears the in-memory store |

- [ ] **Step 1: Create the mock**

Create `tests/create-oidc-client/mock-keycloak.py`:
```python
#!/usr/bin/env python3
"""
Mock Keycloak admin API for integration tests of create-oidc-client.sh.
Listens on $MOCK_PORT (default 18080). Bearer token check is skipped:
we trust the test harness to pass *some* Authorization header.

Auth env (the token endpoint validates these):
  MOCK_SA_ID      (default: ag-flow-provisioner)
  MOCK_SA_SECRET  (default: test-secret)

The 'database' is in-memory and per-process. POST /__reset clears it.
"""
import json
import os
import re
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

SA_ID = os.environ.get("MOCK_SA_ID", "ag-flow-provisioner")
SA_SECRET = os.environ.get("MOCK_SA_SECRET", "test-secret")

# clientId -> {uuid, body}
STORE: dict[str, dict] = {}


def _send_json(handler, status, payload):
    body = json.dumps(payload).encode()
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def _send_empty(handler, status):
    handler.send_response(status)
    handler.send_header("Content-Length", "0")
    handler.end_headers()


class MockHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        # Quiet; bats output is noisy enough.
        pass

    # ----- POST -----------------------------------------------------------
    def do_POST(self):
        parsed = urlparse(self.path)
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length) if length else b""

        if parsed.path == "/__reset":
            STORE.clear()
            return _send_empty(self, 204)

        # /realms/{realm}/protocol/openid-connect/token
        m = re.match(r"^/realms/[^/]+/protocol/openid-connect/token$", parsed.path)
        if m:
            form = parse_qs(raw.decode())
            cid = form.get("client_id", [""])[0]
            secret = form.get("client_secret", [""])[0]
            gt = form.get("grant_type", [""])[0]
            if gt != "client_credentials" or cid != SA_ID or secret != SA_SECRET:
                return _send_json(self, 401, {"error": "invalid_client"})
            return _send_json(self, 200, {
                "access_token": "FAKE-TOKEN",
                "token_type": "Bearer",
                "expires_in": 60,
            })

        # /admin/realms/{realm}/clients  (create)
        m = re.match(r"^/admin/realms/([^/]+)/clients$", parsed.path)
        if m:
            try:
                body = json.loads(raw)
            except json.JSONDecodeError:
                return _send_json(self, 400, {"error": "invalid_json"})
            cid = body.get("clientId")
            if not cid:
                return _send_json(self, 400, {"error": "missing clientId"})
            if cid in STORE:
                return _send_json(self, 409, {"errorMessage": "Client exists"})
            uuid = f"uuid-{cid}"
            STORE[cid] = {"uuid": uuid, "body": body}
            self.send_response(201)
            # Keycloak puts the new resource URL in Location:
            self.send_header("Location", f"{parsed.path}/{uuid}")
            self.send_header("Content-Length", "0")
            self.end_headers()
            return

        return _send_json(self, 404, {"error": "not_found", "path": parsed.path})

    # ----- GET ------------------------------------------------------------
    def do_GET(self):
        parsed = urlparse(self.path)

        # /admin/realms/{realm}/clients?clientId=X
        m = re.match(r"^/admin/realms/([^/]+)/clients$", parsed.path)
        if m:
            qs = parse_qs(parsed.query)
            cid = qs.get("clientId", [""])[0]
            if cid and cid in STORE:
                return _send_json(self, 200, [{
                    "id": STORE[cid]["uuid"],
                    "clientId": cid,
                }])
            return _send_json(self, 200, [])

        # /admin/realms/{realm}/clients/{uuid}/client-secret
        m = re.match(
            r"^/admin/realms/([^/]+)/clients/([^/]+)/client-secret$",
            parsed.path,
        )
        if m:
            uuid = m.group(2)
            for entry in STORE.values():
                if entry["uuid"] == uuid:
                    return _send_json(self, 200, {"value": f"secret-{uuid}"})
            return _send_json(self, 404, {"error": "not_found"})

        return _send_json(self, 404, {"error": "not_found", "path": parsed.path})


def main():
    port = int(os.environ.get("MOCK_PORT", "18080"))
    server = ThreadingHTTPServer(("127.0.0.1", port), MockHandler)
    print(f"mock-keycloak listening on 127.0.0.1:{port}", file=sys.stderr)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Smoke-test the mock manually**

Run in one terminal: `python3 tests/create-oidc-client/mock-keycloak.py`
Expected stderr: `mock-keycloak listening on 127.0.0.1:18080`

Run in another terminal:
```bash
curl -s -X POST 'http://127.0.0.1:18080/realms/test/protocol/openid-connect/token' \
  -d grant_type=client_credentials \
  -d client_id=ag-flow-provisioner \
  -d client_secret=test-secret | jq .
```
Expected output: `{"access_token":"FAKE-TOKEN", ...}`.

Stop the mock with Ctrl+C.

- [ ] **Step 3: Commit**

```bash
git add tests/create-oidc-client/mock-keycloak.py
git commit -m "test(scripts): add mock Keycloak admin API for integration tests"
```

---

## Task 6: HTTP wrapper + `get_access_token`

**Files:**
- Modify: `scripts/create-oidc-client.sh` (add `kc_request`, `get_access_token`)
- Modify: `tests/create-oidc-client/helpers.bash` (mock start/stop helpers)
- Create: `tests/create-oidc-client/test_http.bats`

- [ ] **Step 1: Add mock helpers**

Append to `tests/create-oidc-client/helpers.bash`:
```bash
MOCK_PORT="${MOCK_PORT:-18080}"
MOCK_URL="http://127.0.0.1:${MOCK_PORT}"
MOCK_PID=""

start_mock() {
  # Start mock-keycloak.py in background; wait for port to be ready.
  MOCK_PORT="$MOCK_PORT" python3 "${BATS_TEST_DIRNAME}/mock-keycloak.py" \
    >/dev/null 2>"${BATS_TEST_TMPDIR}/mock.err" &
  MOCK_PID=$!
  local tries=0
  until curl -sf "${MOCK_URL}/__reset" -X POST >/dev/null 2>&1; do
    tries=$((tries + 1))
    if [[ $tries -ge 50 ]]; then
      echo "mock failed to start" >&2
      cat "${BATS_TEST_TMPDIR}/mock.err" >&2
      return 1
    fi
    sleep 0.1
  done
}

stop_mock() {
  if [[ -n "$MOCK_PID" ]]; then
    kill "$MOCK_PID" 2>/dev/null || true
    wait "$MOCK_PID" 2>/dev/null || true
    MOCK_PID=""
  fi
}

reset_mock() {
  curl -sf -X POST "${MOCK_URL}/__reset" >/dev/null
}
```

- [ ] **Step 2: Write failing tests for `get_access_token`**

Create `tests/create-oidc-client/test_http.bats`:
```bash
#!/usr/bin/env bats

load helpers

setup() {
  start_mock
}

teardown() {
  stop_mock
}

@test "get_access_token: valid SA credentials returns access_token" {
  source_script
  parse_args --url "$MOCK_URL" --client-id x --type bearer-only --realm yoops
  KC_SA_CLIENT_ID=ag-flow-provisioner \
  KC_SA_CLIENT_SECRET=test-secret \
  KC_SA_REALM=yoops \
    run get_access_token
  [ "$status" -eq 0 ]
  [ "$output" = "FAKE-TOKEN" ]
}

@test "get_access_token: wrong secret exits 2 with explicit error" {
  source_script
  parse_args --url "$MOCK_URL" --client-id x --type bearer-only --realm yoops
  KC_SA_CLIENT_ID=ag-flow-provisioner \
  KC_SA_CLIENT_SECRET=wrong \
  KC_SA_REALM=yoops \
    run get_access_token
  [ "$status" -eq 2 ]
  [[ "$output" == *"auth"* ]] || [[ "$output" == *"401"* ]]
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bats tests/create-oidc-client/test_http.bats`
Expected: 2 failures (`get_access_token` undefined).

- [ ] **Step 4: Implement `kc_request` + `get_access_token`**

Insert in `scripts/create-oidc-client.sh` after `build_payload`:
```bash
# ----- HTTP wrapper ----------------------------------------------------------

# kc_request <method> <path> [curl_args...]
# Émet le body de la réponse sur stdout. Le code HTTP est exposé dans la
# variable globale KC_LAST_STATUS. Code de retour : 0 succès curl, 2 échec
# réseau (le caller décide quoi faire selon KC_LAST_STATUS).
KC_LAST_STATUS=""
kc_request() {
  local method="$1" path="$2"
  shift 2
  local out_body status
  out_body=$(mktemp)
  if ! status=$(curl -sS -X "$method" \
      -o "$out_body" \
      -w '%{http_code}' \
      "${ARG_URL}${path}" \
      "$@"); then
    err "échec réseau vers ${ARG_URL}${path}"
    rm -f "$out_body"
    return 2
  fi
  KC_LAST_STATUS="$status"
  cat "$out_body"
  rm -f "$out_body"
}

# ----- Auth ------------------------------------------------------------------

# Émet l'access_token sur stdout. Échec → exit code 2 et message sur stderr.
get_access_token() {
  local sa_id="${KC_SA_CLIENT_ID:-ag-flow-provisioner}"
  local sa_realm="${KC_SA_REALM:-yoops}"
  local body
  body=$(kc_request POST "/realms/${sa_realm}/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "client_id=${sa_id}" \
    --data-urlencode "client_secret=${KC_SA_CLIENT_SECRET}") || return 2

  if [[ "$KC_LAST_STATUS" != "200" ]]; then
    err "auth échouée (HTTP $KC_LAST_STATUS) — vérifie KC_SA_CLIENT_ID / KC_SA_CLIENT_SECRET / KC_SA_REALM"
    err "réponse: $body"
    return 2
  fi
  jq -r '.access_token' <<<"$body"
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bats tests/create-oidc-client/test_http.bats`
Expected: 2/2 pass.

- [ ] **Step 6: Commit**

```bash
git add scripts/create-oidc-client.sh tests/create-oidc-client/helpers.bash tests/create-oidc-client/test_http.bats
git commit -m "feat(scripts): add kc_request wrapper and get_access_token"
```

---

## Task 7: `client_exists` + `create_client`

**Files:**
- Modify: `scripts/create-oidc-client.sh` (add `client_exists`, `create_client`)
- Modify: `tests/create-oidc-client/test_http.bats`

- [ ] **Step 1: Write failing tests**

Append to `tests/create-oidc-client/test_http.bats`:
```bash
@test "client_exists: returns 1 (false) when client absent" {
  source_script
  parse_args --url "$MOCK_URL" --client-id newone --type bearer-only --realm yoops
  KC_SA_CLIENT_ID=ag-flow-provisioner KC_SA_CLIENT_SECRET=test-secret \
    run client_exists "FAKE-TOKEN"
  [ "$status" -eq 1 ]
}

@test "client_exists: returns 0 (true) after a client is created" {
  source_script
  parse_args --url "$MOCK_URL" --client-id created --type bearer-only --realm yoops
  # Create directly via curl to populate the mock store.
  curl -sf -X POST "$MOCK_URL/admin/realms/yoops/clients" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer FAKE-TOKEN" \
    -d '{"clientId":"created","protocol":"openid-connect"}'
  run client_exists "FAKE-TOKEN"
  [ "$status" -eq 0 ]
}

@test "create_client: 201 succeeds silently" {
  source_script
  parse_args --url "$MOCK_URL" --client-id brand --type bearer-only --realm yoops
  run create_client "FAKE-TOKEN"
  [ "$status" -eq 0 ]
}

@test "create_client: 409 fails with explicit error (client existant)" {
  source_script
  parse_args --url "$MOCK_URL" --client-id dup --type bearer-only --realm yoops
  curl -sf -X POST "$MOCK_URL/admin/realms/yoops/clients" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer FAKE-TOKEN" \
    -d '{"clientId":"dup","protocol":"openid-connect"}'
  run create_client "FAKE-TOKEN"
  [ "$status" -ne 0 ]
  [[ "$output" == *"existe"* ]] || [[ "$output" == *"409"* ]]
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bats tests/create-oidc-client/test_http.bats`
Expected: 4 new failures.

- [ ] **Step 3: Implement `client_exists` + `create_client`**

Insert in `scripts/create-oidc-client.sh` after `get_access_token`:
```bash
# ----- Client existence / creation -------------------------------------------

# client_exists <access_token>
# Return code 0 si le client existe, 1 sinon. Échec API → return 2.
client_exists() {
  local token="$1"
  local body
  body=$(kc_request GET \
    "/admin/realms/${ARG_REALM}/clients?clientId=$(printf %s "$ARG_CLIENT_ID" | jq -sRr @uri)" \
    -H "Authorization: Bearer ${token}") || return 2

  if [[ "$KC_LAST_STATUS" != "200" ]]; then
    err "lookup client échoué (HTTP $KC_LAST_STATUS): $body"
    return 2
  fi
  local count
  count=$(jq 'length' <<<"$body")
  [[ "$count" -gt 0 ]]
}

# create_client <access_token>
# Return code 0 si créé, 1 si conflit (409), 2 sinon.
create_client() {
  local token="$1"
  local payload
  payload=$(build_payload)
  local body
  body=$(kc_request POST \
    "/admin/realms/${ARG_REALM}/clients" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    --data "$payload") || return 2

  case "$KC_LAST_STATUS" in
    201) return 0 ;;
    409) err "client '${ARG_CLIENT_ID}' existe déjà dans realm '${ARG_REALM}'"; return 1 ;;
    403) err "403 forbidden — le service account n'a pas realm-admin"; return 2 ;;
    *)   err "erreur Keycloak (HTTP $KC_LAST_STATUS): $body"; return 2 ;;
  esac
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bats tests/create-oidc-client/test_http.bats`
Expected: 6/6 pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/create-oidc-client.sh tests/create-oidc-client/test_http.bats
git commit -m "feat(scripts): add client_exists and create_client"
```

---

## Task 8: `get_client_secret` + `emit_result` + `main` glue

**Files:**
- Modify: `scripts/create-oidc-client.sh` (add `get_client_uuid`, `get_client_secret`, `emit_result`, complete `main`)
- Modify: `tests/create-oidc-client/test_http.bats`

- [ ] **Step 1: Write failing tests**

Append to `tests/create-oidc-client/test_http.bats`:
```bash
@test "get_client_secret: returns secret value for confidential client" {
  source_script
  parse_args --url "$MOCK_URL" --client-id conf --type confidential \
    --redirect-uri 'https://x/cb' --realm yoops
  # Pre-populate the mock so the secret endpoint has something to return.
  curl -sf -X POST "$MOCK_URL/admin/realms/yoops/clients" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer FAKE-TOKEN" \
    -d '{"clientId":"conf","protocol":"openid-connect"}'
  run get_client_secret "FAKE-TOKEN"
  [ "$status" -eq 0 ]
  [ "$output" = "secret-uuid-conf" ]
}

@test "end-to-end main: confidential client emits JSON with secret on stdout" {
  reset_mock
  KC_SA_CLIENT_ID=ag-flow-provisioner \
  KC_SA_CLIENT_SECRET=test-secret \
  KC_SA_REALM=yoops \
    run bash "${SCRIPT_PATH}" \
      --url "$MOCK_URL" \
      --client-id e2e-conf \
      --type confidential \
      --redirect-uri 'https://x/cb'
  [ "$status" -eq 0 ]
  [ "$(jq -r '.clientId' <<<"$output")" = "e2e-conf" ]
  [ "$(jq -r '.type' <<<"$output")" = "confidential" ]
  [ "$(jq -r '.secret' <<<"$output")" = "secret-uuid-e2e-conf" ]
  [ "$(jq -r '.realm' <<<"$output")" = "yoops" ]
  [ "$(jq -r '.issuer' <<<"$output")" = "${MOCK_URL}/realms/yoops" ]
  [ "$(jq -r '.well_known' <<<"$output")" = "${MOCK_URL}/realms/yoops/.well-known/openid-configuration" ]
}

@test "end-to-end main: public client emits JSON with null secret" {
  reset_mock
  KC_SA_CLIENT_ID=ag-flow-provisioner \
  KC_SA_CLIENT_SECRET=test-secret \
  KC_SA_REALM=yoops \
    run bash "${SCRIPT_PATH}" \
      --url "$MOCK_URL" \
      --client-id e2e-spa \
      --type public \
      --redirect-uri 'https://app/*'
  [ "$status" -eq 0 ]
  [ "$(jq -r '.type' <<<"$output")" = "public" ]
  [ "$(jq -r '.secret' <<<"$output")" = "null" ]
}

@test "end-to-end main: bearer-only emits JSON with null secret" {
  reset_mock
  KC_SA_CLIENT_ID=ag-flow-provisioner \
  KC_SA_CLIENT_SECRET=test-secret \
  KC_SA_REALM=yoops \
    run bash "${SCRIPT_PATH}" \
      --url "$MOCK_URL" \
      --client-id e2e-api \
      --type bearer-only
  [ "$status" -eq 0 ]
  [ "$(jq -r '.type' <<<"$output")" = "bearer-only" ]
  [ "$(jq -r '.secret' <<<"$output")" = "null" ]
}

@test "end-to-end main: service-account emits secret" {
  reset_mock
  KC_SA_CLIENT_ID=ag-flow-provisioner \
  KC_SA_CLIENT_SECRET=test-secret \
  KC_SA_REALM=yoops \
    run bash "${SCRIPT_PATH}" \
      --url "$MOCK_URL" \
      --client-id e2e-m2m \
      --type service-account
  [ "$status" -eq 0 ]
  [ "$(jq -r '.type' <<<"$output")" = "service-account" ]
  [ "$(jq -r '.secret' <<<"$output")" = "secret-uuid-e2e-m2m" ]
}

@test "end-to-end main: pre-existing client exits 1 with explicit error" {
  reset_mock
  curl -sf -X POST "$MOCK_URL/admin/realms/yoops/clients" \
    -H "Content-Type: application/json" \
    -d '{"clientId":"already-here","protocol":"openid-connect"}'

  KC_SA_CLIENT_ID=ag-flow-provisioner \
  KC_SA_CLIENT_SECRET=test-secret \
  KC_SA_REALM=yoops \
    run bash "${SCRIPT_PATH}" \
      --url "$MOCK_URL" \
      --client-id already-here \
      --type bearer-only
  [ "$status" -eq 1 ]
  [[ "$output" == *"already-here"* ]]
  [[ "$output" == *"existe"* ]]
}

@test "end-to-end main: missing KC_SA_CLIENT_SECRET exits 1" {
  unset KC_SA_CLIENT_SECRET
  run bash "${SCRIPT_PATH}" \
    --url "$MOCK_URL" \
    --client-id x \
    --type bearer-only
  [ "$status" -eq 1 ]
  [[ "$output" == *"KC_SA_CLIENT_SECRET"* ]]
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bats tests/create-oidc-client/test_http.bats`
Expected: 7 new failures (`get_client_secret`/`emit_result` undefined, `main` incomplete).

- [ ] **Step 3: Implement `get_client_uuid`, `get_client_secret`, `emit_result`, complete `main`**

Insert in `scripts/create-oidc-client.sh` after `create_client`:
```bash
# ----- Secret retrieval ------------------------------------------------------

# get_client_uuid <access_token> → UUID sur stdout
get_client_uuid() {
  local token="$1"
  local body
  body=$(kc_request GET \
    "/admin/realms/${ARG_REALM}/clients?clientId=$(printf %s "$ARG_CLIENT_ID" | jq -sRr @uri)" \
    -H "Authorization: Bearer ${token}") || return 2
  [[ "$KC_LAST_STATUS" == "200" ]] || {
    err "lookup UUID échoué (HTTP $KC_LAST_STATUS): $body"
    return 2
  }
  jq -r '.[0].id // empty' <<<"$body"
}

# get_client_secret <access_token> → secret string sur stdout
get_client_secret() {
  local token="$1"
  local uuid
  uuid=$(get_client_uuid "$token") || return 2
  [[ -n "$uuid" ]] || { err "UUID introuvable pour $ARG_CLIENT_ID"; return 2; }

  local body
  body=$(kc_request GET \
    "/admin/realms/${ARG_REALM}/clients/${uuid}/client-secret" \
    -H "Authorization: Bearer ${token}") || return 2
  [[ "$KC_LAST_STATUS" == "200" ]] || {
    err "récupération secret échouée (HTTP $KC_LAST_STATUS): $body"
    return 2
  }
  jq -r '.value' <<<"$body"
}

# ----- Output ---------------------------------------------------------------

# emit_result <secret_or_null>
emit_result() {
  local secret_arg="$1"
  local issuer="${ARG_URL}/realms/${ARG_REALM}"
  local well_known="${issuer}/.well-known/openid-configuration"

  if [[ -z "$secret_arg" ]]; then
    jq -n \
      --arg realm "$ARG_REALM" \
      --arg clientId "$ARG_CLIENT_ID" \
      --arg type "$ARG_TYPE" \
      --arg issuer "$issuer" \
      --arg wk "$well_known" \
      '{realm:$realm, clientId:$clientId, type:$type, secret:null, issuer:$issuer, well_known:$wk}'
  else
    jq -n \
      --arg realm "$ARG_REALM" \
      --arg clientId "$ARG_CLIENT_ID" \
      --arg type "$ARG_TYPE" \
      --arg secret "$secret_arg" \
      --arg issuer "$issuer" \
      --arg wk "$well_known" \
      '{realm:$realm, clientId:$clientId, type:$type, secret:$secret, issuer:$issuer, well_known:$wk}'
  fi
}
```

Replace `main()` (the stub from Task 1) with the full version:
```bash
main() {
  if [[ $# -eq 0 ]]; then
    usage >&2
    exit 1
  fi
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
  esac

  parse_args "$@"
  validate_args || exit 1

  log "[1/5] Authentification (service account ${KC_SA_CLIENT_ID:-ag-flow-provisioner})"
  local token
  token=$(get_access_token) || exit 2

  log "[2/5] Vérification de non-existence du client '${ARG_CLIENT_ID}' dans realm '${ARG_REALM}'"
  # client_exists retourne 0 si présent, 1 si absent (happy path), 2 sur erreur API.
  # On déclare la variable AVANT l'appel pour ne pas que `local` masque le code retour.
  local exists_rc
  set +e
  client_exists "$token"
  exists_rc=$?
  set -e
  case "$exists_rc" in
    0) err "client '${ARG_CLIENT_ID}' existe déjà dans realm '${ARG_REALM}'"; exit 1 ;;
    1) ;; # absent — happy path
    *) exit 2 ;;
  esac

  log "[3/5] Création du client (type=${ARG_TYPE})"
  local create_rc
  set +e
  create_client "$token"
  create_rc=$?
  set -e
  [[ $create_rc -eq 0 ]] || exit "$create_rc"  # 1 si 409, 2 sinon

  local secret=""
  case "$ARG_TYPE" in
    confidential|service-account)
      log "[4/5] Récupération du secret"
      secret=$(get_client_secret "$token") || exit 2
      ;;
    *)
      log "[4/5] (pas de secret pour --type=${ARG_TYPE})"
      ;;
  esac

  log "[5/5] Émission du résultat"
  emit_result "$secret"
}
```

**Pourquoi `set +e` / `set -e`** : `set -e` est actif depuis le top du script. Sans la pause, dès que `client_exists` retourne 1 (absent = happy path), le script terminerait. La pause + capture de `$?` dans une variable déclarée *avant* l'appel évite à la fois la sortie prématurée et le bug bash classique où `local var=$?` réinitialise `$?` à 0.

- [ ] **Step 4: Run all tests to verify they pass**

Run: `bats tests/create-oidc-client/`
Expected: 31 pure tests + 13 http tests = 44 passes total.

- [ ] **Step 5: Commit**

```bash
git add scripts/create-oidc-client.sh tests/create-oidc-client/test_http.bats
git commit -m "feat(scripts): wire up main flow (auth, exists check, create, secret, output)"
```

---

## Task 9: Documentation in script header

**Files:**
- Modify: `scripts/create-oidc-client.sh` (expand the header comment with examples)

- [ ] **Step 1: Replace the top-of-file comment block**

Replace the existing 5-line header in `scripts/create-oidc-client.sh` with:
```bash
#!/usr/bin/env bash
#
# create-oidc-client.sh — crée un client OIDC sur un Keycloak distant
#                         via l'API admin REST.
#
# Authentification : service account (par défaut ag-flow-provisioner,
# rôle realm-admin) avec grant_type=client_credentials.
#
# Spec : docs/superpowers/specs/2026-05-20-keycloak-create-oidc-client-design.md
#
# DÉPENDANCES
#   bash 4+, curl, jq
#
# UTILISATION
#   export KC_SA_CLIENT_SECRET='...'      # obligatoire
#   ./scripts/create-oidc-client.sh \
#     --url <https://kc.example.org|http://192.168.x.y:8080> \
#     --client-id <id> \
#     --type <public|confidential|bearer-only|service-account> \
#     [--realm yoops] [--name ...] [--description ...] [--base-url ...] \
#     [--redirect-uri ... --redirect-uri ...] \
#     [--web-origin ... --web-origin ...]
#
# EXEMPLES
#   # SPA avec PKCE
#   ./scripts/create-oidc-client.sh --url https://security.yoops.org \
#     --client-id mon-spa --type public \
#     --redirect-uri 'https://app.example.org/*' \
#     --redirect-uri 'http://localhost:5173/*'
#
#   # Backend confidential
#   ./scripts/create-oidc-client.sh --url https://security.yoops.org \
#     --client-id mon-back --type confidential \
#     --redirect-uri 'https://api.example.org/oauth2/callback' \
#     | jq -r .secret > .env.secret
#
#   # API bearer-only
#   ./scripts/create-oidc-client.sh --url https://security.yoops.org \
#     --client-id mon-api --type bearer-only
#
#   # Service account M2M
#   ./scripts/create-oidc-client.sh --url https://security.yoops.org \
#     --client-id mon-worker --type service-account | jq -r .secret
#
# OUTPUT
#   stdout : JSON {realm, clientId, type, secret, issuer, well_known}
#   stderr : progression + erreurs
#
# EXIT CODES
#   0  succès
#   1  erreur d'usage / précondition (incl. client déjà existant)
#   2  erreur API Keycloak
#
set -euo pipefail
```

- [ ] **Step 2: Run all tests to confirm nothing regressed**

Run: `bats tests/create-oidc-client/`
Expected: 44/44 still pass.

- [ ] **Step 3: Commit**

```bash
git add scripts/create-oidc-client.sh
git commit -m "docs(scripts): expand create-oidc-client.sh header with usage examples"
```

---

## Task 10: Real-world smoke test (manual, against live Keycloak)

This is the final validation: run the script against the actual Keycloak at `security.yoops.org`, create a throwaway client, verify it appears in the admin UI, then clean it up.

**Files:**
- (none modified — manual validation only)

- [ ] **Step 1: Retrieve the SA secret**

Open `/root/keycloak-credentials.txt` on the LXC (or wherever the secret was written by `03-apply-realm.sh`). Copy the `ag-flow-provisioner` secret to clipboard.

- [ ] **Step 2: Export creds and run the script for a throwaway public client**

```bash
export KC_SA_CLIENT_SECRET='<paste-here>'
./scripts/create-oidc-client.sh \
  --url https://security.yoops.org \
  --client-id smoke-test-DELETE-ME \
  --type public \
  --redirect-uri 'https://example.org/*'
```

Expected stdout (single JSON object):
```json
{"realm":"yoops","clientId":"smoke-test-DELETE-ME","type":"public","secret":null,"issuer":"https://security.yoops.org/realms/yoops","well_known":"https://security.yoops.org/realms/yoops/.well-known/openid-configuration"}
```

Expected stderr: 5 `==> [N/5] ...` log lines, no errors.

- [ ] **Step 3: Verify the client exists in the Keycloak admin UI**

Open `https://security.yoops.org/admin/master/console/#/yoops/clients`, find `smoke-test-DELETE-ME`. Check that:
- Client type = OpenID Connect
- Access type = public
- Standard flow = enabled
- PKCE method = S256 (in Advanced)
- Valid redirect URIs contains `https://example.org/*`
- Web origins contains `https://example.org`

- [ ] **Step 4: Verify the script fails properly on re-run**

```bash
./scripts/create-oidc-client.sh \
  --url https://security.yoops.org \
  --client-id smoke-test-DELETE-ME \
  --type public \
  --redirect-uri 'https://example.org/*'
echo "exit=$?"
```
Expected: stderr contains `client 'smoke-test-DELETE-ME' existe déjà`, exit code = 1.

- [ ] **Step 5: Delete the throwaway client**

Either via the admin UI (Clients → smoke-test-DELETE-ME → Delete), or via `kcadm.sh` on the LXC:
```bash
/opt/keycloak/bin/kcadm.sh delete clients/<uuid> -r yoops
```

- [ ] **Step 6: If all of the above worked, no further commit is needed**

The implementation is complete. Final state: 10 commits, 44 automated tests passing, manual smoke validated.

---

## Self-review checklist (already run by author)

1. **Spec coverage** :
   - Section 2 décisions structurantes → Tasks 1–10 collectivement ✓
   - Section 3 placement (`scripts/create-oidc-client.sh`, sourceable) → Task 1 ✓
   - Section 4 CLI (args obligatoires/optionnels, env vars) → Tasks 2, 3 ✓
   - Section 5 flux d'exécution (5 étapes) → Tasks 6, 7, 8 (main glue) ✓
   - Section 6 mapping `--type` → payload → Task 4 ✓
   - Section 7 output (JSON stdout, stderr, exit codes) → Tasks 8, 9 ✓
   - Section 8 gestion d'erreurs → distribué dans Tasks 3, 6, 7, 8 ✓
   - Section 9 exemples → Task 9 (header doc) + Task 10 (smoke) ✓
   - Section 10 hors-scope → respecté (pas d'update, pas de delete, pas de rôles) ✓
   - Section 11 risques (403 SA, secret in env) → Task 7 (msg 403 explicite) + Task 9 (note env var) ✓

2. **Placeholders** : aucun TBD/TODO. Tous les blocs de code sont complets.

3. **Type consistency** : noms cohérents (`ARG_*`, `KC_LAST_STATUS`, `get_access_token`/`get_client_secret`/`get_client_uuid`, `client_exists`/`create_client`, `emit_result`). Le `parse_args` initialise `ARG_REDIRECT_URIS=()` et `ARG_WEB_ORIGINS=()` à chaque appel, ce qui est utilisé partout en aval.
