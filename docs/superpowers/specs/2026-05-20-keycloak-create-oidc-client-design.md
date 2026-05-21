# Design — `create-oidc-client.sh`

**Date** : 2026-05-20
**Statut** : design validé, prêt pour plan d'implémentation
**Auteur** : g.beard (via brainstorming)

## 1. Contexte et objectif

Le repo `security/keycloak` contient trois scripts de bootstrap (`01-create-lxc.sh`, `02-install-keycloak.sh`, `03-apply-realm.sh`) qui s'exécutent **dans le LXC** via `kcadm.sh` et configurent le realm `yoops`. Le realm définit déjà un service account `ag-flow-provisioner` (client M2M, `client_credentials`, rôle `realm-admin`), explicitement prévu pour le provisioning dynamique de ressources Keycloak depuis l'extérieur.

L'objectif est d'ajouter un **outil d'opération réutilisable** permettant de créer un client OIDC sur n'importe quelle instance Keycloak, sans avoir à se connecter au LXC ni à manipuler `kcadm.sh`. Le script s'utilise depuis une machine de dev, un runner CI, ou n'importe quel host capable d'atteindre l'API admin Keycloak.

## 2. Décisions structurantes (validées lors du brainstorming)

| Décision | Choix retenu | Raison |
|---|---|---|
| Mode d'accès | REST API admin via `curl` | Pas besoin de SSH ; cible passée en argument (URL ou IP) |
| Authentification | Service account `ag-flow-provisioner` (`client_credentials`) | Usage prévu de ce client M2M ; pas de creds humains exposés |
| Types de clients supportés | Générique via `--type` | Couvre les 4 cas du realm yoops (public, confidential, bearer-only, service-account) |
| Idempotence | Erreur explicite si le `clientId` existe | Pas d'écrasement accidentel ; l'opérateur nettoie manuellement avant relance |
| Output | JSON parsable sur stdout, logs sur stderr | Pipeable dans `jq`, automatisable, séparation propre |

## 3. Placement et conventions

- **Chemin** : `scripts/create-oidc-client.sh`
- **Pas de préfixe numérique** : ce n'est pas un script de bootstrap séquentiel mais un outil d'opération
- **Shebang** : `#!/usr/bin/env bash`
- **Flags shell** : `set -euo pipefail`
- **Dépendances runtime** : `bash`, `curl`, `jq`
- **Droits** : exécutable (`chmod +x`)

## 4. Interface CLI

```
create-oidc-client.sh --url <KC_URL> --client-id <id> --type <type> [options]
```

### 4.1 Arguments obligatoires

| Flag | Valeur | Exemple |
|---|---|---|
| `--url` | URL ou IP du Keycloak (sans trailing slash) | `https://security.yoops.org` ou `http://192.168.1.42:8080` |
| `--client-id` | clientId du nouveau client | `mon-app` |
| `--type` | Type de client (cf. section 6) | `public` \| `confidential` \| `bearer-only` \| `service-account` |

### 4.2 Arguments optionnels

| Flag | Défaut | Description |
|---|---|---|
| `--realm` | `yoops` | Realm où créer le client |
| `--name` | (vide) | `name` (displayName) du client |
| `--description` | (vide) | `description` du client |
| `--redirect-uri` | (aucun) | Répétable. Requis pour `public`/`confidential`, refusé sinon |
| `--web-origin` | dérivé de `--redirect-uri` pour `public` | Répétable. Pour `public` uniquement |
| `--base-url` | (vide) | `baseUrl` du client |
| `-h`, `--help` | — | Affiche l'usage |

### 4.3 Variables d'environnement (authentification)

| Variable | Défaut | Description |
|---|---|---|
| `KC_SA_CLIENT_ID` | `ag-flow-provisioner` | clientId du service account |
| `KC_SA_CLIENT_SECRET` | **obligatoire** | Secret du service account ; absence → exit 1 |
| `KC_SA_REALM` | `yoops` | Realm où vit le service account (peut différer de `--realm`) |

## 5. Flux d'exécution

```
[1/5] Validation des arguments
      - clientId non vide
      - type ∈ {public, confidential, bearer-only, service-account}
      - KC_SA_CLIENT_SECRET présent
      - cohérence type/flags (redirect-uri requis pour public/confidential,
        refusés pour bearer-only/service-account)

[2/5] Obtention d'un access_token
      POST <url>/realms/<KC_SA_REALM>/protocol/openid-connect/token
      Content-Type: application/x-www-form-urlencoded
      grant_type=client_credentials
      client_id=<KC_SA_CLIENT_ID>
      client_secret=<KC_SA_CLIENT_SECRET>
      → extraire .access_token via jq

[3/5] Vérification de non-existence
      GET <url>/admin/realms/<realm>/clients?clientId=<id>
      Authorization: Bearer <token>
      → si la liste retournée est non vide : log "client <id> existe déjà"
        sur stderr, exit 1

[4/5] Création du client
      POST <url>/admin/realms/<realm>/clients
      Authorization: Bearer <token>
      Content-Type: application/json
      <payload selon section 6>
      → 201 Created attendu

[5/5] Récupération du secret (si type ∈ {confidential, service-account})
      GET <url>/admin/realms/<realm>/clients?clientId=<id> → extraire .id (UUID)
      GET <url>/admin/realms/<realm>/clients/<uuid>/client-secret → extraire .value

Émission du JSON final sur stdout (cf. section 7).
```

## 6. Mapping `--type` → payload JSON

| Champ JSON | `public` | `confidential` | `bearer-only` | `service-account` |
|---|---|---|---|---|
| `clientId` | `<id>` | `<id>` | `<id>` | `<id>` |
| `protocol` | `openid-connect` | `openid-connect` | `openid-connect` | `openid-connect` |
| `enabled` | `true` | `true` | `true` | `true` |
| `publicClient` | `true` | `false` | `false` | `false` |
| `standardFlowEnabled` | `true` | `true` | `false` | `false` |
| `implicitFlowEnabled` | `false` | `false` | `false` | `false` |
| `directAccessGrantsEnabled` | `false` | `false` | `false` | `false` |
| `serviceAccountsEnabled` | `false` | `false` | `false` | `true` |
| `bearerOnly` | `false` | `false` | `true` | `false` |
| `redirectUris` | depuis flags | depuis flags | (omis) | (omis) |
| `webOrigins` | depuis flags ou dérivé | depuis flags si fourni | (omis) | (omis) |
| `attributes."pkce.code.challenge.method"` | `S256` | (omis) | (omis) | (omis) |
| `name` | si `--name` | si `--name` | si `--name` | si `--name` |
| `description` | si `--description` | si `--description` | si `--description` | si `--description` |
| `baseUrl` | si `--base-url` | si `--base-url` | si `--base-url` | si `--base-url` |

**Notes** :
- Pour `public`, si `--web-origin` n'est pas fourni, on dérive depuis `--redirect-uri` : pour chaque URI `https://host[:port]/...`, on extrait `https://host[:port]`. Évite l'oubli de CORS classique sur SPA.
- `directAccessGrantsEnabled=false` partout : ROPC est désactivé volontairement (aligné avec le realm yoops).
- `implicitFlowEnabled=false` partout : implicit flow est déprécié.

## 7. Output

### 7.1 Stdout (succès)

Un seul objet JSON, sur une ligne (ou pretty-printé par `jq`) :

```json
{
  "realm": "yoops",
  "clientId": "mon-app",
  "type": "confidential",
  "secret": "abc123...",
  "issuer": "https://security.yoops.org/realms/yoops",
  "well_known": "https://security.yoops.org/realms/yoops/.well-known/openid-configuration"
}
```

- `secret` : chaîne pour `confidential` / `service-account`, `null` pour `public` / `bearer-only`
- `issuer` : `<url>/realms/<realm>`
- `well_known` : `<url>/realms/<realm>/.well-known/openid-configuration`

### 7.2 Stderr (progression et erreurs)

- Lignes `==> [N/5] <étape>` pour la progression
- Erreurs : message en clair + dump du body de la réponse Keycloak quand pertinent

### 7.3 Codes de sortie

| Code | Cas |
|---|---|
| `0` | Création réussie |
| `1` | Erreur d'usage, préconditions non remplies (secret manquant, type invalide, client déjà existant) |
| `2` | Erreur API Keycloak (4xx/5xx hors 409) |

## 8. Gestion d'erreurs

| Cas | Détection | Message stderr | Exit |
|---|---|---|---|
| `KC_SA_CLIENT_SECRET` manquant | check shell | `KC_SA_CLIENT_SECRET non défini` | 1 |
| `--type` invalide | check shell | `type invalide: <x> (attendu: public\|confidential\|bearer-only\|service-account)` | 1 |
| `--redirect-uri` sur bearer-only/service-account | check shell | `--redirect-uri n'est pas valide pour --type=<x>` | 1 |
| `--redirect-uri` absent pour public/confidential | check shell | `au moins un --redirect-uri est requis pour --type=<x>` | 1 |
| Token endpoint 401 | code HTTP curl | `auth échouée — vérifie KC_SA_CLIENT_ID/SECRET/REALM` | 2 |
| Client existe déjà | liste non vide étape [3/5] | `client '<id>' existe déjà dans realm '<realm>'` | 1 |
| Create client 403 | code HTTP curl | `403 forbidden — le service account n'a pas realm-admin` | 2 |
| Autre 4xx/5xx | code HTTP curl | `erreur Keycloak (<code>): <body>` | 2 |
| `curl` exit ≠ 0 (réseau) | code shell | `échec réseau vers <url>` | 2 |

**Pas de retry automatique** : l'opérateur relance manuellement si besoin.

## 9. Exemples d'usage

### 9.1 Client public PKCE (SPA)
```bash
export KC_SA_CLIENT_SECRET='...'
./scripts/create-oidc-client.sh \
  --url https://security.yoops.org \
  --client-id mon-spa \
  --type public \
  --redirect-uri 'https://app.example.org/*' \
  --redirect-uri 'http://localhost:5173/*'
```

### 9.2 Client confidential (backend serveur-side)
```bash
export KC_SA_CLIENT_SECRET='...'
./scripts/create-oidc-client.sh \
  --url https://security.yoops.org \
  --client-id mon-backend \
  --type confidential \
  --redirect-uri 'https://api.example.org/oauth2/callback' \
  | jq -r '.secret' > .env.secret
```

### 9.3 Client bearer-only (API qui valide les tokens)
```bash
./scripts/create-oidc-client.sh \
  --url https://security.yoops.org \
  --client-id mon-api \
  --type bearer-only
```

### 9.4 Service account (M2M)
```bash
./scripts/create-oidc-client.sh \
  --url https://security.yoops.org \
  --client-id mon-worker \
  --type service-account \
  | jq -r '.secret'
```

## 10. Hors-scope (volontairement non couvert)

- **Update d'un client existant** : explicitement rejeté (erreur si existe)
- **Suppression d'un client** : pas dans ce script (sera un autre outil si besoin)
- **Gestion des rôles client / mappers** : ce script crée le client nu ; les rôles/mappers sont gérés via un autre outil ou via l'UI
- **Rotation de secret** : pas dans ce script
- **Assignation de rôles realm au service account d'un client `service-account`** : à faire manuellement ou via outil dédié
- **Retry / backoff** : non, échec → exit, opérateur relance
- **Test unitaire shell** : nice-to-have, pas un blocker (le script est petit et le smoke test manuel suffit pour V1)

## 11. Risques et points d'attention

- **Si le service account `ag-flow-provisioner` perd le rôle `realm-admin`**, toutes les créations échouent en 403. Le message d'erreur doit être explicite.
- **Le secret SA en variable d'env** apparaît dans `ps` sur certains systèmes. Recommandation usage : `export KC_SA_CLIENT_SECRET=$(cat ~/.keycloak-sa-secret)` puis exécuter, plutôt que de l'inliner dans la commande.
- **Default `--realm yoops`** : pratique pour le contexte courant, mais à garder à l'esprit lors d'une utilisation sur un autre realm.
