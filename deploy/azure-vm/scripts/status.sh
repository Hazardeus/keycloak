#!/usr/bin/env bash
#
# status.sh — show container status and Keycloak health for the Azure VM stack.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$(dirname "${SCRIPT_DIR}")"
cd "${STACK_DIR}"

docker compose ps

echo ""
echo "==> Keycloak health (depuis l'intérieur du réseau compose) :"
docker compose exec -T keycloak \
  curl -fsS "http://127.0.0.1:8080/health/ready" || echo "    Keycloak pas prêt / injoignable"
# Note: 8080 above is the container-internal port; the host binding is 127.0.0.1:8090.
