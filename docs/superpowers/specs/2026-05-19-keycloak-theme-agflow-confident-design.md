# Keycloak — thème `agflow-confident` (v1)

| Champ | Valeur |
|---|---|
| Date | 2026-05-19 |
| Statut | Spec validée — prêt pour plan d'implémentation |
| Auteurs | g.beard + Claude (session brainstorm) |
| Surface | Realm Keycloak `yoops` (`https://security.yoops.org/realms/yoops`) |
| Périmètre | Login theme + ajout IdP Google + déploiement |

## 1. Contexte et intention

Le realm `yoops` sert aujourd'hui la page d'auth dans le thème par défaut `keycloak.v2`. Deux pistes éditoriales existent déjà en dormance dans `Theme/` (`agflow-premium`, `agflow-nocturne`) mais ne sont pas activées et ne couvrent pas le funnel complet.

L'objectif de cette v1 : remplacer le rendu par défaut par un thème éditorial cohérent appelé **`agflow-confident`**, qui incarne la « voix du maillage » — une entité narratrice discrète qui parle à l'utilisateur en marge du formulaire. L'esthétique reste celle déjà établie en brainstorm (ink + paper + signal-orange, Fraunces + JetBrains Mono).

La direction visuelle retenue est la **direction A** du brainstorm — *le dialogue en marge* : deux colonnes, le manifest gauche héberge un fil de répliques italiques du maillage, le formulaire vit à droite, calme.

Les anciens dossiers `agflow-premium` et `agflow-nocturne` ne sont ni supprimés ni modifiés.

## 2. Décisions structurantes (récap)

| # | Décision | Valeur retenue |
|---|---|---|
| D1 | Nom du thème | `agflow-confident` |
| D2 | Direction visuelle | A — dialogue en marge, 2 colonnes |
| D3 | Périmètre d'écrans | Funnel complet (10 écrans, voir §4.2) |
| D4 | Voix | Figée par écran (pas de variation par état, heure, historique) |
| D5 | Cinétique | Typewriter one-shot par session (flag `sessionStorage`) |
| D6 | i18n | FR + EN via `messages_fr/en.properties`, switcher Keycloak actif |
| D7 | OAuth Google | Bouton « Continuer avec Google » sous le formulaire login |
| D8 | Mobile | Manifest condensé (2 lignes max) empilé au-dessus du formulaire |
| D9 | Light/dark | Auto via `prefers-color-scheme` (pas de bouton visible) |
| D10 | Cleanup legacy | `agflow-premium` et `agflow-nocturne` laissés tels quels |

## 3. Architecture du thème

### 3.1 Emplacement

```
Theme/
├── agflow-premium/                 # legacy — inchangé
├── agflow-nocturne/                # legacy — inchangé
└── agflow-confident/               # nouveau
    └── login/
        ├── theme.properties
        ├── template.ftl
        ├── login.ftl
        ├── login-reset-password.ftl
        ├── login-update-password.ftl
        ├── login-verify-email.ftl
        ├── login-page-expired.ftl
        ├── error.ftl
        ├── terms.ftl
        ├── login-otp.ftl
        ├── login-config-totp.ftl
        ├── info.ftl
        ├── messages/
        │   ├── messages_fr.properties
        │   └── messages_en.properties
        └── resources/
            ├── css/styles.css
            ├── js/maillage.js
            ├── fonts/              # Fraunces, JetBrains Mono — self-hosted
            └── img/                # logo Yoops, glyphs sociaux SVG, favicon
```

### 3.2 Héritage Keycloak

`theme.properties` :

```properties
parent=keycloak.v2
import=common/keycloak

styles=css/styles.css
scripts=js/maillage.js

locales=fr,en

# Permet la substitution ${env.VAR} dans le realm JSON et les FTL
# (déjà supporté nativement par Keycloak >= 25 ; pas de SPI custom)
```

On profite des macros existantes (`<@layout.registrationLayout>`, `<#list social.providers>`, `messagesPerField`) et on n'override que ce qu'on veut diverger : `template.ftl` (layout 2-col), les 10 .ftl listés en §4.2, plus les CSS/JS et messages.

### 3.3 Activation

Dans `yoops-realm.json` :

- `"loginTheme": "keycloak.v2"` → `"loginTheme": "agflow-confident"`
- `accountTheme`, `adminTheme`, `emailTheme` : **inchangés** (hors v1).

### 3.4 Polices

Self-hostées dans `resources/fonts/` pour éviter la dépendance Google Fonts CDN et le risque RGPD :

- **Fraunces** — poids 350 (regular), 350 italic, 400 — variable optique `opsz: auto`, axe `SOFT` activé.
- **JetBrains Mono** — poids 400, 500.

Format `woff2` uniquement (les navigateurs non-`woff2` sont hors cible).

## 4. Système visuel & tokens

### 4.1 Palette

```css
:root {
  /* dark — défaut */
  --ink:        #0d0e10;
  --paper:      #f4ecdc;
  --paper-soft: rgba(244,236,220,0.78);
  --paper-dim:  rgba(244,236,220,0.40);
  --rule:       rgba(244,236,220,0.16);
  --signal:     #ff5b1f;
  --signal-dim: rgba(255,91,31,0.40);
  --field-bg:   transparent;
  --field-line: rgba(244,236,220,0.36);
  --field-line-active: var(--signal);
}

@media (prefers-color-scheme: light) {
  :root {
    --ink:        #f4ecdc;
    --paper:      #1a1a1f;
    --paper-soft: rgba(26,26,31,0.78);
    --paper-dim:  rgba(26,26,31,0.45);
    --rule:       rgba(26,26,31,0.14);
    --signal:     #d9430b;       /* signal-orange ajusté pour contraste AA sur paper */
    --signal-dim: rgba(217,67,11,0.40);
    --field-line: rgba(26,26,31,0.30);
    --field-line-active: var(--signal);
  }
}
```

Le `color-scheme` CSS du UA chrome n'est pas activé — on contrôle l'ensemble du rendu via les tokens.

### 4.2 Typographie

| Token | Famille | Taille / line-height | Usage |
|---|---|---|---|
| `--type-mono-xs` | JetBrains Mono 500, uppercase, letter-spacing 0.18em | 10.5px / 1.4 | labels (`§01 — ACCÈS`) |
| `--type-mono-sm` | JetBrains Mono 400 | 12px / 1.5 | inputs, boutons, divider |
| `--type-serif-body` | Fraunces 350 | 14px / 1.55 | copy générale |
| `--type-serif-line` | Fraunces 350 italic | 16px / 1.4 | répliques du maillage |
| `--type-serif-h2` | Fraunces 350, letter-spacing -0.01em | 28px / 1.2 | titre de page (rare) |
| `--type-serif-display` | Fraunces 300 | 40px / 1.1 | écrans rares (info, terms) |

### 4.3 Rythme, espace, layout

- **Base 8px**. Tokens `--space-1` à `--space-8` = 4/8/12/16/24/32/48/64.
- **Breakpoint unique** : `720px` (viewport, mobile-first).
- **Gouttière** desktop entre les deux colonnes : `--space-7` (48px).
- **Padding page** : `--space-4` mobile, `--space-6` desktop.
- **Ratio colonnes** desktop : manifest 42%, formulaire 58%.

### 4.4 Bordures, focus, cinétique

- Bordures 1px `--rule` partout. Pas de border-radius (esthétique sèche).
- **Focus visible** : `outline: 2px solid var(--signal); outline-offset: -1px;`. Jamais de `box-shadow` glow.
- **Easing standard** : `cubic-bezier(0.2, 0.0, 0, 1)`, durée 220ms.
- **Typewriter** : 30ms/char, 400ms entre lignes (voir §6).
- **`prefers-reduced-motion: reduce`** → toutes anims neutralisées, opacités finales appliquées direct, caret statique.

## 5. Anatomie d'une page

### 5.1 Wireframe desktop (≥ 720px)

```
┌──────────────────────────────────────────────────────────────────┐
│  yoops                                              fr · en  ●○  │
├────────────────────────────────────┬─────────────────────────────┤
│  §01 — ACCÈS                       │                             │
│                                    │   email                     │
│  — Bonjour. Tu reviens.            │   ─────────────             │
│  — J'ai gardé ta place au chaud.   │                             │
│  — Pose ton nom ici ↓              │   mot de passe              │
│                                    │   ─────────────             │
│           [terminal-card]          │                             │
│                                    │   ☐ se souvenir             │
│                                    │   [    Entrer    ]          │
│                                    │   ─── ou ───────            │
│                                    │   [ G  Continuer Google ]   │
│                                    │   Mot de passe oublié       │
├────────────────────────────────────┴─────────────────────────────┤
│  © yoops · confidentialité · CGU                       v.a3f12c  │
└──────────────────────────────────────────────────────────────────┘
   ←—— 42% ——→                          ←——— 58% ———→
```

### 5.2 Wireframe mobile (< 720px)

```
┌────────────────────────────┐
│ yoops              fr · en │
├────────────────────────────┤
│ §01 — ACCÈS                │
│ — J'ai gardé ta place      │   ← manifest condensé : 2 lignes max
│ — Pose ton nom ici ↓       │     pas de terminal-card
├────────────────────────────┤
│  email · ───────           │
│  mot de passe · ───────    │
│  ☐ se souvenir             │
│  [    Entrer    ]          │
│  ─── ou ───                │
│  [ G  Continuer Google ]   │
│  Mot de passe oublié       │
├────────────────────────────┤
│ © yoops · privacy · CGU    │
└────────────────────────────┘
```

### 5.3 Composants partagés (définis dans `template.ftl`)

| Sélecteur | Rôle |
|---|---|
| `<header class="kc-head">` | Logo « yoops » (Fraunces 350, 22px) + locale switcher (mono-xs) |
| `<main class="kc-stage">` | Wrapper grid 2-col desktop → 1-col mobile |
| `<aside class="kc-voice" data-screen="X">` | Manifest gauche : `kc-label` + `kc-lines` + optionnel `kc-terminal-card` |
| `<section class="kc-form">` | Formulaire Keycloak + social-providers + aux links |
| `<footer class="kc-foot">` | © + liens légaux + build hash (`${properties.kcBuildHash!''}`) |

### 5.4 Apparition de `kc-terminal-card`

- Présente sur : `login.ftl`, `login-otp.ftl`.
- Absente sur : `error.ftl`, `login-page-expired.ftl`, `info.ftl`, `login-verify-email.ftl`, `terms.ftl`, `login-reset-password.ftl`, `login-update-password.ftl`, `login-config-totp.ftl` (écrans qui demandent de la clarté, pas du décor).
- Toujours absente en mobile (quel que soit l'écran).

### 5.5 Champs Keycloak

- `<input>` natifs Keycloak conservés, restylés : underline-only (border-bottom 1px), pas de border-box, fond transparent.
- Label flottant au-dessus du champ, mono-sm `--paper-dim`.
- Erreurs `messagesPerField.get('username')` : mono-xs `--signal`, sous le champ, jamais en bulle/tooltip.

## 6. Voix du maillage

### 6.1 Schéma de copy par écran

Chaque écran reçoit dans `<aside class="kc-voice">` :

- un **label** : `§XX — MOT` (mono uppercase) — sert de marqueur de chapitre.
- 2 à 4 **lignes** : italiques Fraunces, chacune préfixée d'un tiret cadratin `—`.

Pas d'autre prose dans la colonne gauche.

### 6.2 Grille de copy v1 — FR

| Écran | Label | Lignes |
|---|---|---|
| `login` | `§01 — ACCÈS` | — Bonjour. Tu reviens.<br>— J'ai gardé ta place au chaud.<br>— Pose ton nom ici ↓ |
| `login-otp` | `§01.5 — VÉRIFIER` | — Encore un signe.<br>— Le code qu'on t'a envoyé, ici. ↓ |
| `login-reset-password` | `§02 — MÉMOIRE` | — Tu as perdu le sceau.<br>— Donne-moi l'adresse, je t'envoie une nouvelle clef. |
| `login-update-password` | `§03 — RENOUVEAU` | — On efface l'ancien sceau.<br>— Choisis-en un que tu retiendras.<br>— Je n'en garde aucune trace. |
| `login-verify-email` | `§02 — ATTENTE` | — Je viens de t'envoyer un mot.<br>— Ouvre-le pour que je sache que c'est bien toi. |
| `login-config-totp` | `§00.5 — APPAREILLAGE` | — Lions ton téléphone à mon souvenir.<br>— Scanne le motif, je le reconnaîtrai après. |
| `terms` | `§00 — PACTE` | — Avant d'entrer, lis ce que nous nous devons.<br>— Si tu acceptes, je le saurai. |
| `info` | `§FIN — RETOUR` | — C'est fait.<br>— Tu peux revenir quand tu veux. |
| `login-page-expired` | `§ÉR — INTERROMPU` | — La conversation s'est rompue.<br>— Reprends depuis le début, je t'attends. |
| `error` | `§ÉR — INCIDENT` | — Quelque chose a glissé entre nous.<br>— Ce n'est pas de ton fait. Réessaie ↓ |

Ligne supplémentaire sur `login` uniquement, rendue dans `kc-voice` comme une 4ème ligne avec un style en retrait :

> — Si ton sceau est ailleurs, prends la porte d'à côté.

Cette ligne a la classe `kc-line-aside`, est rendue avec `--paper-soft` et n'est **pas** typewriter (elle reste visible d'office, en retrait des trois principales). Son placement vertical suit le flux normal de `kc-voice` — pas d'alignement magique avec le divider du formulaire à droite.

### 6.3 Grille de copy v1 — EN (traduction d'esprit)

Traductions à raffiner à la relecture mais cap retenu : préserver le ton (tutoiement → « you » familier, tirets cadratin, sécheresse italique). Exemple `login` :

```
§01 — ACCESS
— Hello. You're back.
— I kept your place warm.
— Lay your name here ↓
```

Pour les neuf autres écrans : traductions livrées dans `messages_en.properties` (rédaction à fixer pendant l'implémentation, validée par revue avant déploiement).

### 6.4 Stockage des clés dans `messages.properties`

Namespace `maillage.*`. Exemple pour `login` :

```properties
# messages_fr.properties
maillage.login.label       = §01 — ACCÈS
maillage.login.line1       = — Bonjour. Tu reviens.
maillage.login.line2       = — J'ai gardé ta place au chaud.
maillage.login.line3       = — Pose ton nom ici ↓
maillage.login.line_google = — Si ton sceau est ailleurs, prends la porte d'à côté.

login.or                   = ou
login.continueWith         = Continuer avec {0}
```

```properties
# messages_en.properties
maillage.login.label       = §01 — ACCESS
maillage.login.line1       = — Hello. You're back.
maillage.login.line2       = — I kept your place warm.
maillage.login.line3       = — Lay your name here ↓
maillage.login.line_google = — If your seal is elsewhere, take the side door.

login.or                   = or
login.continueWith         = Continue with {0}
```

Accès en FTL : `${msg("maillage.login.line1")}`.

### 6.5 Mécanique typewriter (`resources/js/maillage.js`)

1. Au `DOMContentLoaded`, le script lit `<aside class="kc-voice" data-screen="X">` pour récupérer l'identifiant d'écran.
2. La clé `sessionStorage["agflow_confident.seen." + screenId]` est consultée.
3. **Déjà vue** → les lignes sont rendues server-side avec leur texte final, `opacity: 1`, caret final en place. Aucune animation. Le script s'arrête là.
4. **Première visite** → chaque `<p class="kc-line">` est en `opacity: 0`. Le JS révèle la ligne 1, tape caractère par caractère (30ms/char), attend 400ms, passe à la ligne suivante, etc.
5. Quand la dernière ligne est tapée, le caret orange clignote (pseudo-element `::after` avec `animation: blink 1s steps(2) infinite`) et le flag sessionStorage est posé.
6. **`prefers-reduced-motion: reduce`** → le script no-op intégral, lignes en `opacity: 1` direct, caret statique (pas de blink).
7. **JS désactivé** → lignes visibles en rendu serveur (texte présent dans le HTML), pas de typewriter. Graceful degradation.

### 6.6 Cas particulier : écrans d'erreur

Sur `error.ftl` et `login-page-expired.ftl`, le flag sessionStorage est composé `seen.<screenId>.<errorKey>` plutôt que `seen.<screenId>`. L'`errorKey` est un identifiant stable dérivé de l'erreur côté JS : on prend `error.errorMessage` si exposé par Keycloak, sinon un hash 32-bit stable de `message.summary` (algorithme `cyrb53` ou équivalent, dépendance zéro). Conséquence : chaque nouvelle erreur rejoue le typewriter — c'est voulu, parce que le moment d'erreur compte. Deux apparitions consécutives de la *même* erreur ne re-déclenchent pas l'animation.

## 7. OAuth Google + realm

### 7.1 Déclaration de l'IdP

Ajout au realm JSON :

```json
"identityProviders": [
  {
    "alias": "google",
    "displayName": "Google",
    "providerId": "google",
    "enabled": true,
    "trustEmail": true,
    "storeToken": false,
    "addReadTokenRoleOnCreate": false,
    "firstBrokerLoginFlowAlias": "first broker login",
    "config": {
      "clientId":     "${env.GOOGLE_CLIENT_ID}",
      "clientSecret": "${env.GOOGLE_CLIENT_SECRET}",
      "hostedDomain": "",
      "useJwksUrl":   "true",
      "syncMode":     "IMPORT",
      "defaultScope": "openid email profile"
    }
  }
]
```

### 7.2 Gestion du secret

Le fichier `client_secret_658719250765-7u337hn14l9agvbhnh2j6g9fv821pnb4.apps.googleusercontent.com.json` est aujourd'hui en clair dans le repo. Plan de remédiation, exécuté en étape 0 du déploiement :

1. Ajouter `client_secret_*.json` à `.gitignore`.
2. **Rotater le secret côté Google Cloud Console** (le secret actuel doit être considéré comme compromis dès lors qu'il a transité dans un repo, même privé).
3. Retirer le fichier du repo (`git rm`) — et si l'historique du repo a été poussé quelque part, faire un `git filter-repo` ou équivalent pour le purger.
4. Déposer le nouveau fichier dans `/root/keycloak/` sur le LXC (hors git).

### 7.3 Extension de `03-apply-realm.sh`

Le script lit le fichier `client_secret_*.json` localement et exporte les variables avant l'import :

```bash
if compgen -G "client_secret_*.apps.googleusercontent.com.json" > /dev/null; then
  GOOGLE_JSON=$(ls client_secret_*.apps.googleusercontent.com.json | head -1)
  export GOOGLE_CLIENT_ID=$(jq -r '.web.client_id // .installed.client_id' "$GOOGLE_JSON")
  export GOOGLE_CLIENT_SECRET=$(jq -r '.web.client_secret // .installed.client_secret' "$GOOGLE_JSON")
else
  echo "WARN: client_secret_*.json absent — login Google sera désactivé tant que tu ne pousses pas le fichier dans le LXC." >&2
fi
```

Les variables sont consommées par Keycloak via la substitution `${env.VAR}` dans le realm JSON (supportée nativement depuis Keycloak 25.x).

### 7.4 Rendu du bouton dans `login.ftl`

```ftl
<#if realm.password && social?? && social.providers?has_content>
  <div class="kc-divider"><span>${msg("login.or")}</span></div>

  <div class="kc-social">
    <#list social.providers as p>
      <a class="kc-social-btn kc-social-${p.alias}"
         href="${p.loginUrl}"
         data-provider="${p.alias}">
        <span class="kc-social-glyph">
          <#include "resources/img/social-${p.alias}.svg.ftl">
        </span>
        <span class="kc-social-label">
          ${msg("login.continueWith", p.displayName!p.alias)}
        </span>
      </a>
    </#list>
  </div>
</#if>
```

Style :

- Bouton **secondaire** : bordure 1px `--rule`, fond transparent, label en mono-sm `--paper`.
- Hover : bordure passe à `--signal`, glyph idem.
- Pas de couleur Google officielle (#4285F4). Glyph SVG mono-couleur en `--paper`.

### 7.5 Ordre vertical dans la colonne formulaire de `login.ftl`

1. Champ email
2. Champ mot de passe
3. Lien « Mot de passe oublié »
4. Checkbox « Se souvenir de moi »
5. Bouton submit « Entrer »
6. Divider « ou »
7. Liste social-providers (Google pour la v1)
8. (footer global plus bas, hors `kc-form`)

### 7.6 Premier login Google — trou cosmétique assumé

Quand un utilisateur arrive via Google sans encore exister localement, Keycloak l'envoie sur `idp-review-user-profile.ftl` (selon flow `first broker login`). On **n'override pas** cet écran en v1 — Keycloak rend son template par défaut. À reprendre en v2.

## 8. Explicitement hors v1

| Domaine | Pourquoi pas v1 |
|---|---|
| `account` theme | Reste `keycloak.v3`. Pas touché. |
| `email` theme | Reste `keycloak`. La SPI Novu de remplacement (cf. mémoire `novu_integration`) est un chantier à part. |
| `admin` theme | Reste `keycloak.v2`. Hors surface publique. |
| `register.ftl` | Registration désactivée dans le realm. |
| `idp-review-user-profile.ftl` | Trou cosmétique assumé après premier login Google. |
| Voix adaptative (heure / historique / erreur) | Voix figée par écran (D4). |
| Toggle light/dark visible | Auto-only via `prefers-color-scheme` (D9). |
| Autres social providers | Google seul. Microsoft/Apple/GitHub : si jamais, s'empilent via la macro générique. |
| Page-transitions, animations boutons élaborées | Hover signal-orange standard, point. |
| Mobile drawer voix | Empilement condensé (D8). |
| Storage au-delà du flag `sessionStorage seen.*` | Aucun. |

## 9. Plan de livraison (résumé)

```
ÉTAPE 0 — prep / sécurité
  0.1 gitignore client_secret_*.json
  0.2 rotater le secret Google Cloud
  0.3 git rm + purge historique si publié ailleurs
  0.4 déposer le nouveau fichier dans /root/keycloak/ (LXC)

ÉTAPE 1 — squelette thème
  1.1 mkdir Theme/agflow-confident/login/
  1.2 theme.properties (parent=keycloak.v2)
  1.3 fonts Fraunces + JetBrains Mono dans resources/fonts/ + @font-face
  1.4 update Theme/README.txt

ÉTAPE 2 — design tokens
  2.1 resources/css/styles.css : CSS vars dark + light auto
  2.2 typo, espacements, breakpoint, focus

ÉTAPE 3 — layout partagé
  3.1 template.ftl : grid 2-col + header + footer
  3.2 macro <@maillage.voice screen="X"/>

ÉTAPE 4 — login.ftl + JS
  4.1 login.ftl complet (form + social + voix)
  4.2 resources/js/maillage.js : typewriter + sessionStorage + reduced-motion
  4.3 test 1ère visite vs reload, JS off, reduced-motion, mobile

ÉTAPE 5 — écrans restants
  5.1–5.9 — les 9 autres .ftl du périmètre

ÉTAPE 6 — i18n
  6.1 messages_fr.properties (maillage.* + overrides Keycloak)
  6.2 messages_en.properties (idem)

ÉTAPE 7 — realm + IdP
  7.1 yoops-realm.json : ajouter identityProviders[google]
  7.2 yoops-realm.json : loginTheme = agflow-confident
  7.3 étendre 03-apply-realm.sh

ÉTAPE 8 — QA finale
  8.1 déploiement LXC + kc.sh build + restart
  8.2 walk 10 écrans × fr/en × dark/light × mobile/desktop × JS on/off × reduced-motion
  8.3 end-to-end Google login
  8.4 brute-force lockout test
```

## 10. Critères de succès

- Les 10 écrans du périmètre s'affichent dans `agflow-confident`, jamais en fallback `keycloak.v2`.
- Typewriter joue à la 1ère visite uniquement (sauf erreurs, où le flag inclut l'`errorCode`).
- Locale switcher FR ↔ EN fonctionne sur tous les écrans, copy maillage cohérente dans les deux langues.
- `prefers-color-scheme: light` rend correctement, contraste AA partout.
- Viewport < 720px : pas de scroll horizontal, formulaire au-dessus de la ligne de flottaison.
- JS désactivé : pages lisibles, lignes du maillage présentes, aucun blocage fonctionnel.
- `prefers-reduced-motion: reduce` : aucune animation jouée, lignes statiques, caret non clignotant.
- Login Google end-to-end fonctionnel (clic bouton → consent Google → retour → user créé dans le realm).
- Brute-force lockout (5 fails) déclenche le rendu de `error.ftl` avec sa voix correcte.
- `git log` ne contient plus `client_secret_*.apps.googleusercontent.com.json`.

## 11. Annexe — exemples FTL et CSS

### 11.1 `theme.properties` complet

```properties
parent=keycloak.v2
import=common/keycloak

styles=css/styles.css
scripts=js/maillage.js

locales=fr,en
```

### 11.2 Squelette `template.ftl`

```ftl
<#macro registrationLayout displayMessage=true displayRequiredFields=false displayWide=false showAnotherWayIfPresent=true>
<!DOCTYPE html>
<html lang="${locale.currentLanguageTag}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${realm.displayName!realm.name} — ${msg("loginTitle")}</title>
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body class="kc-body">

  <header class="kc-head">
    <a class="kc-brand" href="${url.loginUrl}">${realm.displayName!"yoops"}</a>
    <#if realm.internationalizationEnabled && locale.supported?size gt 1>
      <nav class="kc-locale">
        <#list locale.supported as l>
          <a class="kc-locale-link <#if l.languageTag == locale.currentLanguageTag>is-current</#if>"
             href="${l.url}">${l.languageTag}</a>
        </#list>
      </nav>
    </#if>
  </header>

  <main class="kc-stage">
    <#nested "voice">
    <section class="kc-form">
      <#nested "form">
    </section>
  </main>

  <footer class="kc-foot">
    <span>© ${.now?string('yyyy')} yoops</span>
    <a href="/privacy">${msg("legal.privacy")}</a>
    <a href="/terms">${msg("legal.terms")}</a>
  </footer>

  <script src="${url.resourcesPath}/js/maillage.js" defer></script>
</body>
</html>
</#macro>
```

### 11.3 Macro `<@maillage.voice/>` (extrait)

```ftl
<#macro voice screen showGoogleLine=false>
<aside class="kc-voice" data-screen="${screen}">
  <div class="kc-label">${msg("maillage." + screen + ".label")}</div>
  <div class="kc-lines">
    <#list 1..4 as i>
      <#assign key = "maillage." + screen + ".line" + i>
      <#if msg(key)?length gt 0 && msg(key) != key>
        <p class="kc-line">${msg(key)}</p>
      </#if>
    </#list>
  </div>
  <#if showGoogleLine>
    <p class="kc-line kc-line-aside">${msg("maillage." + screen + ".line_google")}</p>
  </#if>
  <#if screen == "login" || screen == "login-otp">
    <div class="kc-terminal-card" aria-hidden="true">
      <span class="kc-terminal-label">access</span>
    </div>
  </#if>
</aside>
</#macro>
```

## 12. Risques et points de vigilance

| Risque | Mitigation |
|---|---|
| Secret Google compromis dans l'historique git | Rotation obligatoire en étape 0 |
| Substitution `${env.VAR}` indispo en Keycloak < 25 | Le LXC tourne ≥ 26 (cf. `02-install-keycloak.sh`). Vérifier au déploiement. |
| Police Fraunces variable mal supportée IE/Safari ancien | Hors cible — utilisateurs modernes uniquement |
| Mention `idp-review-user-profile.ftl` rendu en `keycloak.v2` rompt l'expérience | Documenté comme trou v1 ; reprendre v2 |
| `messagesPerField` change de structure entre majors Keycloak | Bloquer une version dans `02-install-keycloak.sh` ; tester avant upgrade |
| Caret clignotant peut être perçu comme « il y a une erreur » | Coupé en `reduced-motion` ; durée d'animation 1s steps(2) reste sobre |
