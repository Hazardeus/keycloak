#!/usr/bin/env bash
#
# 03-apply-realm.sh
# À exécuter DANS le LXC après 02-install-keycloak.sh.
# Importe/met à jour le realm `yoops` depuis realms/yoops-realm.json,
# régénère le secret du service-account `ag-flow-provisioner` et l'écrit
# dans /root/keycloak-credentials.txt.
#
# Idempotent : peut être relancé sans casse.
#
set -euo pipefail

KC_HOME="/opt/keycloak"
KCADM="${KC_HOME}/bin/kcadm.sh"
REALM_NAME="yoops"
REALM_FILE="${1:-/root/yoops-realm.json}"
ADMIN_USER="${KC_ADMIN:-admin}"
ADMIN_PASSWORD="${KC_ADMIN_PASSWORD:-}"
SERVER_URL="${KC_SERVER_URL:-http://127.0.0.1:8080}"
CREDS_FILE="/root/keycloak-credentials.txt"

if [ -z "${ADMIN_PASSWORD}" ]; then
  echo "ERREUR : passe KC_ADMIN_PASSWORD en variable d'env" >&2
  echo "  export KC_ADMIN_PASSWORD='...'" >&2
  echo "  bash $0" >&2
  exit 1
fi

if [ ! -f "${REALM_FILE}" ]; then
  echo "ERREUR : fichier realm introuvable : ${REALM_FILE}" >&2
  exit 1
fi

echo "==> [1/4] Authentification kcadm"
"${KCADM}" config credentials \
  --server "${SERVER_URL}" \
  --realm master \
  --user "${ADMIN_USER}" \
  --password "${ADMIN_PASSWORD}"

echo "==> [2/4] Import / mise à jour du realm '${REALM_NAME}'"
if "${KCADM}" get "realms/${REALM_NAME}" >/dev/null 2>&1; then
  echo "    realm existe déjà — mise à jour partielle"
  "${KCADM}" update "realms/${REALM_NAME}" -f "${REALM_FILE}"
else
  echo "    création du realm"
  "${KCADM}" create realms -f "${REALM_FILE}"
fi

echo "==> [3/4] Régénération du secret pour ag-flow-provisioner"
# Récupère l'UUID du client
CLIENT_UUID=$("${KCADM}" get clients -r "${REALM_NAME}" \
  -q clientId=ag-flow-provisioner --fields id --format csv --noquotes | tail -n1)

if [ -z "${CLIENT_UUID}" ]; then
  echo "ERREUR : client ag-flow-provisioner introuvable" >&2
  exit 1
fi

# Génère un nouveau secret
NEW_SECRET=$("${KCADM}" create "clients/${CLIENT_UUID}/client-secret" \
  -r "${REALM_NAME}" --fields value --format csv --noquotes | tail -n1)

# Assigne le rôle realm-admin au service-account (pour permettre provisioning dynamique)
SA_USER_ID=$("${KCADM}" get "clients/${CLIENT_UUID}/service-account-user" \
  -r "${REALM_NAME}" --fields id --format csv --noquotes | tail -n1)

# Le client 'realm-management' existe dans tous les realms, on lui prend le rôle realm-admin
REALM_MGMT_ID=$("${KCADM}" get clients -r "${REALM_NAME}" \
  -q clientId=realm-management --fields id --format csv --noquotes | tail -n1)

"${KCADM}" add-roles -r "${REALM_NAME}" \
  --uid "${SA_USER_ID}" \
  --cclientid realm-management \
  --rolename realm-admin || echo "    (rôle realm-admin déjà assigné)"

echo "==> [4/4] Écriture des credentials"
cat >> "${CREDS_FILE}" <<EOF

---
Realm '${REALM_NAME}' — $(date -Iseconds)
=========================================

Realm public URL    : https://security.yoops.org/realms/${REALM_NAME}
Issuer (OIDC)       : https://security.yoops.org/realms/${REALM_NAME}
Well-known          : https://security.yoops.org/realms/${REALM_NAME}/.well-known/openid-configuration

Service account (M2M)
  client_id         : ag-flow-provisioner
  client_secret     : ${NEW_SECRET}
  grant_type        : client_credentials

Test de token :
  curl -s -X POST https://security.yoops.org/realms/${REALM_NAME}/protocol/openid-connect/token \\
    -d grant_type=client_credentials \\
    -d client_id=ag-flow-provisioner \\
    -d client_secret='${NEW_SECRET}' | jq .

Clients OIDC
  hitl-console (public, PKCE)  → https://hitl.langgraph.yoops.org
  hitl-api     (bearer-only)   → backend FastAPI
EOF

chmod 600 "${CREDS_FILE}"

echo ""
echo "============================================================"
echo " Realm '${REALM_NAME}' appliqué"
echo " Credentials mis à jour dans ${CREDS_FILE}"
echo "============================================================"
