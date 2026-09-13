#!/usr/bin/env bash
#
# up.sh — start the Azure VM Keycloak stack (dedicated Postgres + Keycloak).
# Run from anywhere; resolves paths relative to this script.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$(dirname "${SCRIPT_DIR}")"
cd "${STACK_DIR}"

if [ ! -f ".env" ]; then
  echo "ERREUR : .env introuvable dans ${STACK_DIR}" >&2
  echo "  cp .env.example .env   # puis édite les valeurs" >&2
  exit 1
fi

docker compose --env-file .env up -d

echo ""
echo "==> Stack démarrée. Keycloak est lié à 127.0.0.1:8080 sur cette VM uniquement."
echo "    Accès depuis ton poste via tunnel SSH, ex. :"
echo "      ssh -N -L 8080:127.0.0.1:8080 <user>@<azure-vm-ip>"
echo "    Puis ouvre http://127.0.0.1:8080"
