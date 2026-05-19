# Keycloak themes — répertoire

Trois thèmes coexistent :

- `agflow-confident/`  → thème courant (login), direction "dialogue en marge".
                         Activé via loginTheme=agflow-confident dans yoops-realm.json.
- `agflow-premium/`    → legacy, non activé. Conservé pour référence.
- `agflow-nocturne/`   → legacy, non activé. Conservé pour référence.

## Installation LXC

cp -r agflow-confident /opt/keycloak/themes/

## Dev — désactiver le cache des templates

/opt/keycloak/bin/kc.sh start \
  --spi-theme-static-max-age=-1 \
  --spi-theme-cache-themes=false \
  --spi-theme-cache-templates=false
