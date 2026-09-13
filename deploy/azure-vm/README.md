# Keycloak sur Azure VM — déploiement AG-Flow (lab / bootstrap)

Ce déploiement est **indépendant** du déploiement Proxmox/LXC situé à la racine
du dépôt. Il ne le remplace pas et ne le modifie pas. Voir [`AGENTS.md`](./AGENTS.md)
pour les règles suivies par les agents IA qui travaillent ici.

## Périmètre actuel

- Keycloak + PostgreSQL dédié + realm `agflow` + admin bootstrap + scripts de backup.
- Pas encore configuré : fédération Entra ID, clients OIDC applicatifs
  (Portal, Docflow, RAG, Harpocrate, Workflow).
- Réseau : Keycloak est lié à `127.0.0.1` sur la VM Azure. Aucun port n'est
  exposé publiquement. L'accès se fait via tunnel SSH.

## Architecture

```
Ton poste
   │  ssh -L 8080:127.0.0.1:8080 <user>@<azure-vm-ip>
   ▼
VM Azure
   ├─ docker compose
   │    ├─ keycloak   (127.0.0.1:8080 → conteneur:8080)
   │    └─ postgres   (dédié Keycloak, pas de port exposé sur l'hôte)
```

## Prérequis sur la VM

- Docker Engine + plugin Compose v2 (`docker compose version`).

## Démarrage

```bash
cd deploy/azure-vm
cp .env.example .env
# édite .env : mots de passe Postgres + admin bootstrap
./scripts/up.sh
```

`.env` n'est jamais commité (voir `.gitignore` à la racine).

## Accès via tunnel SSH

Depuis ton poste :

```bash
ssh -N -L 8080:127.0.0.1:8080 <user>@<azure-vm-ip>
```

Puis ouvre `http://127.0.0.1:8080` et connecte-toi avec les identifiants
`KC_BOOTSTRAP_ADMIN_USERNAME` / `KC_BOOTSTRAP_ADMIN_PASSWORD` définis dans `.env`.

> Note : le bootstrap admin n'est créé qu'au premier démarrage (base vide).
> Si tu changes ces valeurs après coup, gère l'utilisateur admin depuis la
> console Keycloak plutôt que de recréer la stack.

## Realm

Le realm `agflow` est importé automatiquement au démarrage depuis
[`realm/agflow-realm.json`](./realm/agflow-realm.json) (option `--import-realm`).
Il est volontairement minimal : pas de client applicatif pour l'instant.

## Opérations

```bash
./scripts/status.sh   # état des conteneurs + health check Keycloak
./scripts/backup.sh    # dump Postgres compressé dans ./backups/ (git-ignoré)
./scripts/down.sh      # arrête la stack, conserve les données
./scripts/down.sh --volumes   # arrête ET supprime les données (destructif, confirmation requise)
```

## Ce que ce déploiement ne fait pas (encore)

- Pas de reverse proxy / TLS public — accès uniquement via tunnel SSH.
- Pas de fédération Entra ID.
- Pas de clients OIDC pour Portal, Docflow, RAG, Harpocrate ou Workflow.
- Pas de réutilisation de l'instance PostgreSQL applicative AG-Flow —
  Keycloak a sa propre base dédiée.
