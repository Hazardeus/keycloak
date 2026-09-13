#!/usr/bin/env bash
#
# backup.sh — dump the dedicated Keycloak Postgres database to a local file.
# Reads DB credentials from .env. Output goes to ./backups/ (git-ignored).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$(dirname "${SCRIPT_DIR}")"
cd "${STACK_DIR}"

if [ ! -f ".env" ]; then
  echo "ERREUR : .env introuvable dans ${STACK_DIR}" >&2
  exit 1
fi

# shellcheck disable=SC1091
set -a; source .env; set +a

BACKUP_DIR="${STACK_DIR}/backups"
mkdir -p "${BACKUP_DIR}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_FILE="${BACKUP_DIR}/keycloak-${TIMESTAMP}.sql.gz"

echo "==> Dump de la base '${POSTGRES_DB}' vers ${OUT_FILE}"
docker compose exec -T postgres \
  pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" | gzip > "${OUT_FILE}"

echo "==> Backup terminé : ${OUT_FILE}"
