# Agflow Premium Keycloak Theme

## Installation LXC

```bash
cp -r agflow-premium /opt/keycloak/themes/
```

Ensuite active le thème `agflow-premium` dans :
- Realm Settings
- Themes
- Login Theme

Pour forcer le refresh en dev :

```bash
/opt/keycloak/bin/kc.sh start \
  --spi-theme-static-max-age=-1 \
  --spi-theme-cache-themes=false \
  --spi-theme-cache-templates=false
```
