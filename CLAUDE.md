# CLAUDE.md

## Créer un client OIDC

Le script `scripts/create-oidc-client.sh` crée un client OIDC dans un realm Keycloak via `kcadm.sh`. Il est déployé sur le serveur Keycloak à `/root/create-oidc-client.sh` (root@192.168.10.90, clé `~/.ssh/id_shellia`).

### Exécution à distance

```bash
ssh -i ~/.ssh/id_shellia root@192.168.10.90 \
  "KC_ADMIN_PASSWORD='...' /root/create-oidc-client.sh --realm yoops --client-id mon-app --type confidential --redirect-uri 'https://app.example.org/oauth2/callback'"
```

### Options

```
--realm <name>       Realm cible (obligatoire)
--client-id <id>     clientId du nouveau client, [A-Za-z0-9._-]+ (obligatoire)
--type <type>        public | confidential (défaut) | bearer-only | service-account
--redirect-uri <uri> Répétable. Requis pour public/confidential, refusé pour bearer-only/service-account
```

Variables d'environnement :
- `KC_ADMIN_PASSWORD` — obligatoire, mot de passe admin master
- `KC_ADMIN` — défaut `admin`
- `KC_SERVER_URL` — défaut `http://127.0.0.1:8080`
- `KC_HOME` — défaut `/opt/keycloak`

### Types de client

- **public** — SPA/mobile, PKCE (S256) activé automatiquement, pas de secret
- **confidential** — backend serveur-side, secret retourné
- **bearer-only** — API qui ne fait que valider des tokens, pas de redirect-uri, pas de secret
- **service-account** — client machine-à-machine (client credentials grant), secret retourné

### Sortie

Dernière ligne sur stdout, un objet JSON :
```json
{"clientId":"mon-app","clientSecret":"abc123-..."}
```
`clientSecret` vaut `null` pour `public` et `bearer-only`. Extraction sans `jq` :
```bash
grep -oP '"clientSecret":"\K[^"]+'
```

Le script échoue (exit 1) si le `clientId` existe déjà dans le realm — pas d'écrasement silencieux.

Exit codes : `0` OK, `1` erreur d'usage/validation, `2` erreur Keycloak (auth, création, secret).

### Exemples prêts à l'emploi

`scripts/examples/create-backend-api.sh` et `scripts/examples/create-frontend-spa.sh` montrent l'appel complet (backend confidential avec écriture d'un `.env`, SPA public).

## Accès SSH

Voir la mémoire du projet pour les détails de connexion — en résumé : `ssh -i ~/.ssh/id_shellia root@192.168.10.90`, pas d'usage du MCP `ssh-manager`.
