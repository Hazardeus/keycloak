#!/usr/bin/env bash
#
# Exemple : créer un client OIDC public (SPA avec PKCE) pour une app frontend.
#
# Préreq :
#   - exécuté sur la machine Keycloak (kcadm.sh dispo dans /opt/keycloak/bin/)
#   - export KC_ADMIN_PASSWORD='...'   (mot de passe admin master)
#
# Adapte les valeurs ci-dessous avant de lancer.

set -euo pipefail

CLIENT_ID="ma-nouvelle-app"
REALM="yoops"

# URIs autorisées (prod + dev local). webOrigins est dérivé automatiquement.
REDIRECT_URIS=(
  "https://${CLIENT_ID}.yoops.org/*"
  "http://localhost:5173/*"
)

# Construit les flags --redirect-uri répétés à partir du tableau.
REDIRECT_FLAGS=()
for uri in "${REDIRECT_URIS[@]}"; do
  REDIRECT_FLAGS+=( --redirect-uri "$uri" )
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/../create-oidc-client.sh" \
  --realm "$REALM" \
  --client-id "$CLIENT_ID" \
  --type public \
  "${REDIRECT_FLAGS[@]}"

# Note : pour une SPA publique, pas de clientSecret (la réponse aura
# clientSecret: null). L'app utilise PKCE S256 côté navigateur.
