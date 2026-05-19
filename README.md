# Keycloak sur LXC Proxmox — procédure

## Architecture

```
Internet
   │
   ▼
Cloudflare (TLS termination, auth.yoops.org)
   │
   ▼  Cloudflare Tunnel
LXC Proxmox (ex. CTID 210, 192.168.10.42)
   ├─ cloudflared (service)
   ├─ keycloak (systemd, écoute sur 127.0.0.1:8080)
   └─ postgresql (local, port 5432)
```

TLS se termine chez Cloudflare. À l'intérieur du LXC tout est en clair sur
localhost, ce qui simplifie énormément la config (pas de cert à gérer côté
Keycloak). `proxy-headers=xforwarded` dit à Keycloak de croire le header
`X-Forwarded-Proto: https` injecté par cloudflared.

## 1. Sur le host Proxmox

```bash
# Adapte CTID / IP / STORAGE aux valeurs de ton homelab avant de lancer
CTID=210 IP=192.168.10.42/24 GATEWAY=192.168.10.1 \
  bash 01-create-lxc.sh
```

## 2. Dans le LXC

```bash
pct push 210 02-install-keycloak.sh /root/02-install-keycloak.sh
pct exec 210 -- bash /root/02-install-keycloak.sh
```

Les credentials générés sont sauvegardés dans `/root/keycloak-credentials.txt`
à l'intérieur du LXC. Récupère-les immédiatement :

```bash
pct exec 210 -- cat /root/keycloak-credentials.txt
```

…et range-les dans ton gestionnaire de mots de passe.

## 3. Cloudflare Tunnel

Deux approches, selon ton infra :

### Option A — cloudflared dans le même LXC

```bash
pct exec 210 -- bash -c '
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
    tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/cloudflared.list
  apt-get update && apt-get install -y cloudflared
'
```

Puis authentifie et crée le tunnel :

```bash
pct exec 210 -- cloudflared tunnel login
pct exec 210 -- cloudflared tunnel create keycloak
```

Crée `/etc/cloudflared/config.yml` dans le LXC :

```yaml
tunnel: <tunnel-uuid>
credentials-file: /root/.cloudflared/<tunnel-uuid>.json

ingress:
  - hostname: auth.yoops.org
    service: http://127.0.0.1:8080
  - service: http_status:404
```

Route DNS + service :

```bash
pct exec 210 -- cloudflared tunnel route dns keycloak auth.yoops.org
pct exec 210 -- cloudflared service install
pct exec 210 -- systemctl enable --now cloudflared
```

### Option B — ajouter à ton tunnel existant

Si tu as déjà un cloudflared qui gère `admin.langgraph`, `hitl.langgraph`
etc., ajoute simplement une entrée d'ingress :

```yaml
ingress:
  - hostname: auth.yoops.org
    service: http://192.168.10.42:8080
  # ... tes autres entrées ...
```

…et dans ce cas **change** dans `/opt/keycloak/conf/keycloak.conf` :
```
http-host=0.0.0.0
```
puis `systemctl restart keycloak`. Keycloak écoutera alors sur l'IP LAN
du LXC au lieu de `127.0.0.1`.

⚠️ Si tu fais ça, pense à restreindre l'accès au port 8080 depuis le LAN
uniquement (iptables/nftables ou firewall Proxmox).

## 4. Premier login

1. Ouvre `https://auth.yoops.org/admin`
2. Login avec les credentials du fichier
3. **Change le mot de passe admin** via l'UI (Account → Account security)
4. Édite le service systemd pour retirer le bootstrap :

```bash
pct exec 210 -- sed -i '/KC_BOOTSTRAP_ADMIN/d' /etc/systemd/system/keycloak.service
pct exec 210 -- systemctl daemon-reload
pct exec 210 -- systemctl restart keycloak
```

## Opérations courantes

```bash
# Logs
journalctl -u keycloak -f

# Status
systemctl status keycloak

# Rebuild après modif de keycloak.conf
sudo -u keycloak /opt/keycloak/bin/kc.sh build
systemctl restart keycloak

# Backup DB (à automatiser via cron)
sudo -u postgres pg_dump keycloak > /var/backups/keycloak-$(date +%F).sql
```

## Mise à jour de version

```bash
# Dans le LXC
systemctl stop keycloak
# Backup DB avant !
sudo -u postgres pg_dump keycloak > /var/backups/keycloak-pre-upgrade-$(date +%F).sql

# Re-lance 02-install-keycloak.sh avec KC_VERSION=<nouvelle>
# Le script réutilise la DB existante (idempotent sur la partie Postgres)
KC_VERSION=26.1.0 bash 02-install-keycloak.sh
```

Keycloak applique automatiquement ses migrations de schéma au démarrage.
