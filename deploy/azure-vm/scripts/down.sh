#!/usr/bin/env bash
#
# down.sh — stop the Azure VM Keycloak stack.
# By default this PRESERVES data (named volume untouched).
# Pass --volumes to also destroy the Postgres data volume (destructive).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$(dirname "${SCRIPT_DIR}")"
cd "${STACK_DIR}"

if [ "${1:-}" = "--volumes" ]; then
  echo "ATTENTION : suppression du volume de données Postgres (irréversible)."
  read -r -p "Confirmer ? (yes/no) " CONFIRM
  if [ "${CONFIRM}" != "yes" ]; then
    echo "Annulé."
    exit 1
  fi
  docker compose down --volumes
else
  docker compose down
fi
