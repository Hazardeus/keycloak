#!/usr/bin/env bash
#
# 02-install-keycloak.sh
# À exécuter DANS le LXC (en root).
# Installe PostgreSQL 15, Java 21, Keycloak 26.x en binaire natif + systemd.
#
set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================
KC_VERSION="${KC_VERSION:-26.0.7}"
KC_HOSTNAME="${KC_HOSTNAME:-security.yoops.org}"   # Le nom public exposé par Cloudflare Tunnel
KC_HTTP_PORT="${KC_HTTP_PORT:-8080}"
KC_BIND_ADDR="${KC_BIND_ADDR:-127.0.0.1}"      # Cloudflared tourne sur la même machine → localhost

# Admin bootstrap (utilisé UNIQUEMENT au premier démarrage pour créer l'admin)
KC_ADMIN="${KC_ADMIN:-admin}"
KC_ADMIN_PASSWORD="${KC_ADMIN_PASSWORD:-$(openssl rand -base64 24)}"

# PostgreSQL
PG_DB="${PG_DB:-keycloak}"
PG_USER="${PG_USER:-keycloak}"
PG_PASSWORD="${PG_PASSWORD:-$(openssl rand -base64 24)}"

# Chemins
KC_HOME="/opt/keycloak"
KC_USER="keycloak"

# ============================================================================
echo "==> [1/7] Mise à jour système + dépendances"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
  curl ca-certificates gnupg lsb-release \
  postgresql postgresql-contrib \
  openjdk-21-jre-headless \
  unzip tar

# ============================================================================
echo "==> [2/7] Configuration PostgreSQL"
systemctl enable --now postgresql

# Idempotent : on ne recrée pas si déjà présent
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${PG_USER}'" | grep -q 1; then
  sudo -u postgres psql <<SQL
CREATE USER ${PG_USER} WITH PASSWORD '${PG_PASSWORD}';
CREATE DATABASE ${PG_DB} OWNER ${PG_USER};
GRANT ALL PRIVILEGES ON DATABASE ${PG_DB} TO ${PG_USER};
SQL
  echo "    DB et user créés"
else
  echo "    DB/user déjà présents — skip"
  # Dans ce cas le mot de passe dans ce script ne correspond pas à celui stocké.
  # On ré-aligne :
  sudo -u postgres psql -c "ALTER USER ${PG_USER} WITH PASSWORD '${PG_PASSWORD}';" >/dev/null
  echo "    mot de passe Postgres ré-aligné"
fi

# ============================================================================
echo "==> [3/7] Utilisateur système keycloak"
if ! id "${KC_USER}" &>/dev/null; then
  useradd -r -m -U -d "${KC_HOME}" -s /bin/false "${KC_USER}"
fi

# ============================================================================
echo "==> [4/7] Téléchargement Keycloak ${KC_VERSION}"
cd /tmp
KC_ARCHIVE="keycloak-${KC_VERSION}.tar.gz"
if [ ! -f "${KC_ARCHIVE}" ]; then
  curl -fsSL -o "${KC_ARCHIVE}" \
    "https://github.com/keycloak/keycloak/releases/download/${KC_VERSION}/${KC_ARCHIVE}"
fi

# Extraction (on nettoie l'ancienne install sauf les data importantes — ici pas de data locale, tout est en DB)
rm -rf "${KC_HOME}"
mkdir -p "${KC_HOME}"
tar -xzf "${KC_ARCHIVE}" -C "${KC_HOME}" --strip-components=1
chown -R "${KC_USER}:${KC_USER}" "${KC_HOME}"

# ============================================================================
echo "==> [5/7] Configuration Keycloak (conf/keycloak.conf)"
cat > "${KC_HOME}/conf/keycloak.conf" <<EOF
# ====== Database ======
db=postgres
db-url=jdbc:postgresql://localhost:5432/${PG_DB}
db-username=${PG_USER}
db-password=${PG_PASSWORD}

# ====== HTTP ======
# TLS est terminé par Cloudflare Tunnel. Keycloak écoute en clair sur localhost uniquement.
http-enabled=true
http-host=${KC_BIND_ADDR}
http-port=${KC_HTTP_PORT}

# ====== Hostname (v2 API, Keycloak 26+) ======
hostname=https://${KC_HOSTNAME}
# Cloudflare fait le TLS → Keycloak est en mode 'edge' : il croit le header X-Forwarded-Proto
proxy-headers=xforwarded

# ====== Production ======
# Logs
log=console
log-level=INFO
EOF

chown "${KC_USER}:${KC_USER}" "${KC_HOME}/conf/keycloak.conf"
chmod 640 "${KC_HOME}/conf/keycloak.conf"

# ============================================================================
echo "==> [6/7] Build optimisé (kc.sh build)"
# Le build fige la conf db/features → démarrages plus rapides ensuite
sudo -u "${KC_USER}" "${KC_HOME}/bin/kc.sh" build

# ============================================================================
echo "==> [7/7] Service systemd"
cat > /etc/systemd/system/keycloak.service <<EOF
[Unit]
Description=Keycloak Identity and Access Management
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=${KC_USER}
Group=${KC_USER}
# Bootstrap admin : variables lues UNIQUEMENT au 1er démarrage pour créer l'admin initial.
# Une fois l'admin créé, tu peux retirer ces lignes et faire 'systemctl daemon-reload && restart'.
Environment=KC_BOOTSTRAP_ADMIN_USERNAME=${KC_ADMIN}
Environment=KC_BOOTSTRAP_ADMIN_PASSWORD=${KC_ADMIN_PASSWORD}
ExecStart=${KC_HOME}/bin/kc.sh start --optimized
Restart=on-failure
RestartSec=10
LimitNOFILE=102642

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now keycloak

echo ""
echo "==> Attente démarrage Keycloak (peut prendre 30-60s au premier lancement)"
for i in {1..60}; do
  if curl -fsS "http://127.0.0.1:${KC_HTTP_PORT}/health/ready" >/dev/null 2>&1; then
    echo "    Keycloak prêt"
    break
  fi
  sleep 2
done

# ============================================================================
# Credentials dump — à mettre en lieu sûr (ton gestionnaire de mdp)
CREDS_FILE="/root/keycloak-credentials.txt"
cat > "${CREDS_FILE}" <<EOF
Keycloak installation — $(date -Iseconds)
=========================================

Admin console     : https://${KC_HOSTNAME}/admin
  Username        : ${KC_ADMIN}
  Password        : ${KC_ADMIN_PASSWORD}

PostgreSQL
  Database        : ${PG_DB}
  User            : ${PG_USER}
  Password        : ${PG_PASSWORD}
  DSN             : postgresql://${PG_USER}:${PG_PASSWORD}@localhost:5432/${PG_DB}

Fichiers
  Home            : ${KC_HOME}
  Conf            : ${KC_HOME}/conf/keycloak.conf
  Service         : /etc/systemd/system/keycloak.service

Commandes utiles
  systemctl status keycloak
  journalctl -u keycloak -f
  sudo -u ${KC_USER} ${KC_HOME}/bin/kc.sh show-config
EOF
chmod 600 "${CREDS_FILE}"

echo ""
echo "============================================================"
echo " Keycloak installé et démarré"
echo ""
echo " Credentials sauvegardés dans ${CREDS_FILE}"
echo ""
echo " Prochaine étape : configure Cloudflare Tunnel pour router"
echo "   https://${KC_HOSTNAME}  →  http://127.0.0.1:${KC_HTTP_PORT}"
echo ""
echo " Après 1ère connexion admin : édite ${KC_HOME}/conf/keycloak.conf"
echo " et supprime les deux lignes KC_BOOTSTRAP_ADMIN_* du service,"
echo " puis : systemctl daemon-reload && systemctl restart keycloak"
echo "============================================================"
