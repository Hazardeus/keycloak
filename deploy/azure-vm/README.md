# Keycloak sur Azure VM — déploiement AG-Flow (lab / bootstrap)

Ce déploiement est **indépendant** du déploiement Proxmox/LXC situé à la racine
du dépôt. Il ne le remplace pas et ne le modifie pas. Voir [`AGENTS.md`](./AGENTS.md)
pour les règles suivies par les agents IA qui travaillent ici.

## Périmètre actuel

- Keycloak + PostgreSQL dédié + realm `yoops` + admin bootstrap + scripts de backup.
- Le realm s'appelle `yoops` (et non `agflow`) pour rester compatible avec le
  contrat d'identité de l'écosystème AG-Flow/Yoops existant (rôles/groupes),
  tout en restant un déploiement Keycloak entièrement indépendant (base de
  données, admin et secrets propres — rien n'est partagé avec le LXC).
- Pas encore configuré : fédération Entra ID, clients OIDC applicatifs
  (Portal, Docflow, RAG, Harpocrate, Workflow).
- Réseau : Keycloak est lié à `127.0.0.1` sur la VM Azure. Aucun port n'est
  exposé publiquement. L'accès se fait via tunnel SSH.

## Architecture

```
Ton poste
   │  ssh -L 18090:127.0.0.1:8090 <user>@<azure-vm-ip>
   ▼
VM Azure
   ├─ docker compose
   │    ├─ keycloak   (127.0.0.1:8090 → conteneur:8080)
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
ssh -N -L 18090:127.0.0.1:8090 <user>@<azure-vm-ip>
```

Puis ouvre `http://127.0.0.1:18090` et connecte-toi avec les identifiants
`KC_BOOTSTRAP_ADMIN_USERNAME` / `KC_BOOTSTRAP_ADMIN_PASSWORD` définis dans `.env`.

> Note : le bootstrap admin n'est créé qu'au premier démarrage (base vide).
> Si tu changes ces valeurs après coup, gère l'utilisateur admin depuis la
> console Keycloak plutôt que de recréer la stack.

## Realm

Le realm `yoops` est importé automatiquement au démarrage depuis
[`realm/yoops-realm.json`](./realm/yoops-realm.json) (option `--import-realm`).
Il est volontairement minimal : pas de client applicatif pour l'instant.

### Modèle d'identité

| Rôle realm | Type | Composite de | Rôle |
|---|---|---|---|
| `yoops-user` | base | — | Utilisateur standard Yoops |
| `yoops-admin` | base | — | Admin Yoops |
| `agflow-user` | base | — | Accès HITL console AG-Flow |
| `agflow-developer` | base | — | Accès outils/dev AG-Flow |
| `agflow-admin` | base | — | Admin AG-Flow |
| `dev` | compatibilité | → `agflow-user` | Équivalent utilisateur Portal régulier — **n'implique pas** `agflow-developer` |
| `admin` | compatibilité | → `agflow-admin`, `agflow-user` | Équivalent admin Portal (admin AG-Flow + accès Portal normal) |

Groupes (les rôles de compatibilité sont assignés explicitement à chaque
groupe — les composites Keycloak sont directionnels, donc on ne compte pas
uniquement sur la résolution de composite pour obtenir le token effectif
attendu) :

| Groupe | Rôles realm assignés |
|---|---|
| `/yoops` | `yoops-user` |
| `/agflow` | `yoops-user`, `agflow-user`, `dev` |
| `/developers` | `yoops-user`, `agflow-user`, `agflow-developer`, `dev` |
| `/admins` | `yoops-user`, `yoops-admin`, `agflow-user`, `agflow-admin`, `dev`, `admin` |

**TODO :** `verifyEmail` est à `false` tant qu'on est en phase labo (pas de
SMTP configuré sur cette instance). À revisiter une fois qu'un serveur SMTP
ou la fédération Entra ID sera configuré(e).

### Coexistence avec un realm `agflow` existant

Si un realm `agflow` existe déjà dans le Postgres Keycloak déployé (résultat
d'un déploiement précédent), il n'est **pas** supprimé, renommé ni modifié par
l'import du realm `yoops`. Les deux realms peuvent coexister temporairement.
Le plan est : importer/valider `yoops` → migrer la config OIDC des
applications → supprimer manuellement l'ancien realm `agflow` plus tard. Cette
suppression ne doit jamais être automatisée.

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
