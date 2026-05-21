#!/usr/bin/env bash
#
# Exemple : créer un client OIDC confidential pour un backend serveur-side,
# et sauvegarder le clientSecret dans un fichier .env local.
#
# Préreq :
#   - exécuté sur la machine Keycloak (kcadm.sh dispo dans /opt/keycloak/bin/)
#   - export KC_ADMIN_PASSWORD='...'   (mot de passe admin master)
#
# Adapte les valeurs ci-dessous avant de lancer.

set -euo pipefail

CLIENT_ID="mon-backend"
REALM="yoops"
CALLBACK_URI="https://${CLIENT_ID}.yoops.org/oauth2/callback"
OUTPUT_ENV="/root/${CLIENT_ID}.env"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULT=$("${SCRIPT_DIR}/../create-oidc-client.sh" \
  --realm "$REALM" \
  --client-id "$CLIENT_ID" \
  --type confidential \
  --redirect-uri "$CALLBACK_URI")

# Le RESULT est : {"clientId":"...","clientSecret":"..."}
# Extraction sans dépendance jq.
SECRET=$(printf '%s' "$RESULT" | grep -oP '"clientSecret":"\K[^"]+')

# Écriture du .env avec permissions restreintes.
umask 077
cat > "$OUTPUT_ENV" <<EOF
OIDC_ISSUER=https://security.yoops.org/realms/${REALM}
OIDC_CLIENT_ID=${CLIENT_ID}
OIDC_CLIENT_SECRET=${SECRET}
OIDC_REDIRECT_URI=${CALLBACK_URI}
EOF

echo ""
echo "==> Client '${CLIENT_ID}' créé."
echo "==> Credentials écrits dans : ${OUTPUT_ENV}"
echo "==> N'oublie pas de copier ce fichier sur le serveur applicatif."
