# `agflow-confident` Keycloak theme — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Livrer le thème de login Keycloak `agflow-confident` (direction A — *dialogue en marge*) couvrant les 10 écrans du funnel auth du realm `yoops`, avec login Google et bascule auto light/dark, déployé sur le LXC Proxmox.

**Architecture:** Theme Keycloak FreeMarker héritant de `keycloak.v2`. Layout 2-col desktop / empilé mobile via CSS grid. Voix figée par écran stockée dans `messages_<lang>.properties`. Typewriter one-shot par session (sessionStorage flag), `prefers-reduced-motion` honoré. IdP Google déclaré via substitution `${env.VAR}` dans le realm JSON. Anciens dossiers `agflow-premium` et `agflow-nocturne` laissés intacts.

**Tech Stack:** Keycloak ≥ 26 · FreeMarker (FTL) · CSS vars (dark + light auto) · Fraunces (variable, optique) + JetBrains Mono (self-hosted woff2) · JS vanilla (typewriter) · `bash` + `jq` côté déploiement · LXC Proxmox (CTID 210, 192.168.10.42).

**Spec :** `docs/superpowers/specs/2026-05-19-keycloak-theme-agflow-confident-design.md`

---

## File Structure

| Fichier | Action | Responsabilité |
|---|---|---|
| `.gitignore` | Create *(repo non-initialisé aujourd'hui — création du repo dans Task 1)* | Exclure `client_secret_*.json` |
| `Theme/agflow-confident/login/theme.properties` | Create | Hérite `keycloak.v2`, déclare CSS + JS + locales |
| `Theme/agflow-confident/login/template.ftl` | Create | Layout 2-col + header + footer + macro `voice` |
| `Theme/agflow-confident/login/login.ftl` | Create | Formulaire email/password + social providers (Google) |
| `Theme/agflow-confident/login/login-otp.ftl` | Create | Code OTP |
| `Theme/agflow-confident/login/login-reset-password.ftl` | Create | Saisie email pour reset |
| `Theme/agflow-confident/login/login-update-password.ftl` | Create | Changement de mot de passe forcé |
| `Theme/agflow-confident/login/login-verify-email.ftl` | Create | Page « vérifie ton email » |
| `Theme/agflow-confident/login/login-page-expired.ftl` | Create | Session expirée |
| `Theme/agflow-confident/login/login-config-totp.ftl` | Create | Setup TOTP |
| `Theme/agflow-confident/login/error.ftl` | Create | Erreur générique |
| `Theme/agflow-confident/login/terms.ftl` | Create | CGU |
| `Theme/agflow-confident/login/info.ftl` | Create | Message info terminal |
| `Theme/agflow-confident/login/messages/messages_fr.properties` | Create | Toutes les clés `maillage.*` + overrides Keycloak en FR |
| `Theme/agflow-confident/login/messages/messages_en.properties` | Create | Idem en EN |
| `Theme/agflow-confident/login/resources/css/styles.css` | Create | Tokens, layout, composants, typewriter |
| `Theme/agflow-confident/login/resources/js/maillage.js` | Create | Typewriter + sessionStorage + reduced-motion |
| `Theme/agflow-confident/login/resources/fonts/*.woff2` | Create | Fraunces 350/400 + italic + JetBrains Mono 400/500 |
| `Theme/agflow-confident/login/resources/img/social-google.svg.ftl` | Create | Glyph G mono-couleur |
| `Theme/agflow-confident/login/resources/img/favicon.svg` | Create | Favicon yoops |
| `yoops-realm.json` | Modify | Add `identityProviders[google]` + flip `loginTheme` |
| `03-apply-realm.sh` | Modify | Extract Google secret depuis `client_secret_*.json` + export `GOOGLE_*` env |
| `Theme/README.txt` | Modify | Mentionner `agflow-confident` |

---

## Task 1: Initialiser le repo git + sécuriser le secret Google

**Files:**
- Create: `.gitignore`
- Delete: `client_secret_658719250765-7u337hn14l9agvbhnh2j6g9fv821pnb4.apps.googleusercontent.com.json`
- Manuel hors-code: rotation du secret côté Google Cloud Console

- [ ] **Step 1: Vérifier l'absence de repo git**

Run: `cd E:/srcs/security/keycloak && git status 2>&1 | head -1`
Expected: `fatal: not a git repository (or any of the parent directories): .git`

- [ ] **Step 2: Initialiser le repo**

Run :
```bash
cd E:/srcs/security/keycloak
git init -b main
git config user.email "llm.beard.family@gmail.com"
git config user.name "g.beard"
```

Expected: `Initialized empty Git repository in ...`

- [ ] **Step 3: Écrire `.gitignore`**

Create `E:/srcs/security/keycloak/.gitignore` :
```
# secrets
client_secret_*.json
*.local.env

# brainstorm / tooling éphémère
.superpowers/

# OS
.DS_Store
Thumbs.db
```

- [ ] **Step 4: ROTATION DU SECRET GOOGLE — action manuelle hors code**

**STOP avant de continuer.** Va sur https://console.cloud.google.com/apis/credentials, sélectionne le client OAuth `658719250765-7u337hn14l9agvbhnh2j6g9fv821pnb4`, clique **« Reset secret »**. Télécharge le nouveau JSON. Renomme-le en `client_secret_google_yoops.json` et place-le **hors du repo** (par ex. dans `E:/srcs/security/_secrets/`).

Ne passe pas au step 5 tant que la rotation n'est pas faite.

- [ ] **Step 5: Supprimer l'ancien fichier compromis**

Run:
```bash
rm E:/srcs/security/keycloak/client_secret_658719250765-7u337hn14l9agvbhnh2j6g9fv821pnb4.apps.googleusercontent.com.json
```

Expected: pas de sortie, le fichier disparaît de la racine.

- [ ] **Step 6: Premier commit**

Run:
```bash
cd E:/srcs/security/keycloak
git add .gitignore 01-create-lxc.sh 02-install-keycloak.sh 03-apply-realm.sh README.md keycloak.code-workspace yoops-realm.json brief.me Theme/ docs/
git status
```

Vérifie que `client_secret_*.json` n'apparaît pas dans la liste à committer.

```bash
git commit -m "chore: initialize repo with existing keycloak provisioning + ignore client_secret files"
```

Expected: commit créé sur `main`, fichier secret absent du commit.

---

## Task 2: Squelette `agflow-confident` + theme.properties + README

**Files:**
- Create: `Theme/agflow-confident/login/theme.properties`
- Create: `Theme/agflow-confident/login/resources/css/styles.css` (placeholder vide commenté pour permettre le build Keycloak)
- Create: `Theme/agflow-confident/login/resources/js/maillage.js` (placeholder vide)
- Modify: `Theme/README.txt`

- [ ] **Step 1: Créer l'arborescence**

Run:
```bash
mkdir -p E:/srcs/security/keycloak/Theme/agflow-confident/login/messages
mkdir -p E:/srcs/security/keycloak/Theme/agflow-confident/login/resources/css
mkdir -p E:/srcs/security/keycloak/Theme/agflow-confident/login/resources/js
mkdir -p E:/srcs/security/keycloak/Theme/agflow-confident/login/resources/fonts
mkdir -p E:/srcs/security/keycloak/Theme/agflow-confident/login/resources/img
```

- [ ] **Step 2: Écrire `theme.properties`**

Create `Theme/agflow-confident/login/theme.properties`:
```properties
parent=keycloak.v2
import=common/keycloak

styles=css/styles.css
scripts=js/maillage.js

locales=fr,en
```

- [ ] **Step 3: Placeholder CSS + JS pour permettre le build Keycloak**

Create `Theme/agflow-confident/login/resources/css/styles.css`:
```css
/* agflow-confident — styles complets injectés au Task 4 */
```

Create `Theme/agflow-confident/login/resources/js/maillage.js`:
```js
// agflow-confident — typewriter injecté au Task 6
```

- [ ] **Step 4: Mettre à jour le README**

Modify `Theme/README.txt` (remplacer tout le contenu) :
```
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
```

- [ ] **Step 5: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/ Theme/README.txt
git commit -m "feat(theme): scaffold agflow-confident login theme"
```

---

## Task 3: Télécharger les polices self-hostées

**Files:**
- Create: `Theme/agflow-confident/login/resources/fonts/JetBrainsMono-Regular.woff2`
- Create: `Theme/agflow-confident/login/resources/fonts/JetBrainsMono-Medium.woff2`
- Create: `Theme/agflow-confident/login/resources/fonts/Fraunces-Variable.woff2`
- Create: `Theme/agflow-confident/login/resources/fonts/Fraunces-Italic-Variable.woff2`
- Create: `scripts/download-fonts.sh`

- [ ] **Step 1: Écrire un script de téléchargement reproductible**

Create `E:/srcs/security/keycloak/scripts/download-fonts.sh` :
```bash
#!/usr/bin/env bash
# Télécharge les polices self-hostées pour agflow-confident.
# Idempotent : skip si déjà présent.

set -euo pipefail

DEST="$(cd "$(dirname "$0")/.." && pwd)/Theme/agflow-confident/login/resources/fonts"
mkdir -p "$DEST"

declare -A FONTS=(
  ["JetBrainsMono-Regular.woff2"]="https://github.com/JetBrains/JetBrainsMono/raw/v2.304/fonts/webfonts/JetBrainsMono-Regular.woff2"
  ["JetBrainsMono-Medium.woff2"]="https://github.com/JetBrains/JetBrainsMono/raw/v2.304/fonts/webfonts/JetBrainsMono-Medium.woff2"
)

for name in "${!FONTS[@]}"; do
  if [[ -f "$DEST/$name" ]]; then
    echo "skip $name (déjà présent)"
  else
    echo "fetch $name"
    curl -fL -o "$DEST/$name" "${FONTS[$name]}"
  fi
done

# Fraunces : on récupère le woff2 variable depuis le CDN Google Fonts
# (URL pinning via une révision figée — si l'URL casse, mettre à jour manuellement).
FRAUNCES_CSS="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300..400;1,9..144,300..400&display=swap"
for slot in "Fraunces-Variable.woff2:0,9..144" "Fraunces-Italic-Variable.woff2:1,9..144"; do
  fname="${slot%%:*}"
  axis="${slot##*:}"
  if [[ -f "$DEST/$fname" ]]; then
    echo "skip $fname (déjà présent)"
    continue
  fi
  echo "fetch $fname"
  url=$(curl -fsSL -H "User-Agent: Mozilla/5.0" "$FRAUNCES_CSS" \
    | awk -v axis="$axis" '/font-style/{style=$2} /src:/{src=$0} /font-stretch|unicode-range|}/{
        if (src && index(src, ".woff2")) {
          if ((axis ~ /^0,/ && style ~ /normal/) || (axis ~ /^1,/ && style ~ /italic/)) {
            match(src, /https:\/\/[^)]+\.woff2/); print substr(src, RSTART, RLENGTH); exit
          }
        }
        src=""
      }')
  if [[ -z "$url" ]]; then
    echo "ERREUR: impossible d'extraire l'URL woff2 pour $fname depuis $FRAUNCES_CSS" >&2
    echo "Télécharge manuellement Fraunces variable depuis https://fonts.google.com/specimen/Fraunces" >&2
    exit 1
  fi
  curl -fL -o "$DEST/$fname" "$url"
done

echo "OK — polices dans $DEST :"
ls -la "$DEST"
```

```bash
chmod +x E:/srcs/security/keycloak/scripts/download-fonts.sh
```

- [ ] **Step 2: Exécuter le script**

Run:
```bash
bash E:/srcs/security/keycloak/scripts/download-fonts.sh
```

Expected: 4 fichiers `.woff2` listés dans `Theme/agflow-confident/login/resources/fonts/`.

- [ ] **Step 3: Vérifier les fichiers**

Run:
```bash
ls -la E:/srcs/security/keycloak/Theme/agflow-confident/login/resources/fonts/
```

Expected: les 4 woff2 présents, taille > 20 KB chacun.

- [ ] **Step 4: Commit**

```bash
cd E:/srcs/security/keycloak
git add scripts/download-fonts.sh Theme/agflow-confident/login/resources/fonts/
git commit -m "feat(theme): self-host Fraunces + JetBrains Mono woff2"
```

---

## Task 4: CSS tokens, layout, composants

**Files:**
- Modify: `Theme/agflow-confident/login/resources/css/styles.css` (remplacement intégral)

- [ ] **Step 1: Écrire la feuille de style complète**

Remplace tout le contenu de `Theme/agflow-confident/login/resources/css/styles.css` par :

```css
/* agflow-confident — direction A "dialogue en marge"
   Spec: docs/superpowers/specs/2026-05-19-keycloak-theme-agflow-confident-design.md
*/

/* ---------- Fonts ---------- */
@font-face {
  font-family: 'Fraunces';
  font-style: normal;
  font-weight: 300 400;
  font-display: swap;
  src: url('../fonts/Fraunces-Variable.woff2') format('woff2-variations');
}
@font-face {
  font-family: 'Fraunces';
  font-style: italic;
  font-weight: 300 400;
  font-display: swap;
  src: url('../fonts/Fraunces-Italic-Variable.woff2') format('woff2-variations');
}
@font-face {
  font-family: 'JetBrains Mono';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url('../fonts/JetBrainsMono-Regular.woff2') format('woff2');
}
@font-face {
  font-family: 'JetBrains Mono';
  font-style: normal;
  font-weight: 500;
  font-display: swap;
  src: url('../fonts/JetBrainsMono-Medium.woff2') format('woff2');
}

/* ---------- Tokens ---------- */
:root {
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

  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 24px;
  --space-6: 32px;
  --space-7: 48px;
  --space-8: 64px;

  --ease: cubic-bezier(0.2, 0.0, 0, 1);
  --dur: 220ms;
}
@media (prefers-color-scheme: light) {
  :root {
    --ink:        #f4ecdc;
    --paper:      #1a1a1f;
    --paper-soft: rgba(26,26,31,0.78);
    --paper-dim:  rgba(26,26,31,0.45);
    --rule:       rgba(26,26,31,0.14);
    --signal:     #d9430b;
    --signal-dim: rgba(217,67,11,0.40);
    --field-line: rgba(26,26,31,0.30);
  }
}

/* ---------- Reset + base ---------- */
*, *::before, *::after { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body.kc-body {
  min-height: 100vh;
  background: var(--ink);
  color: var(--paper);
  font-family: 'Fraunces', Georgia, serif;
  font-weight: 350;
  font-size: 14px;
  line-height: 1.55;
  display: flex;
  flex-direction: column;
}
a { color: inherit; text-decoration: none; transition: color var(--dur) var(--ease); }
a:hover { color: var(--signal); }

/* ---------- Header ---------- */
.kc-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-5) var(--space-6);
  border-bottom: 1px solid var(--rule);
}
@media (max-width: 720px) {
  .kc-head { padding: var(--space-4); }
}
.kc-brand {
  font-family: 'Fraunces', serif;
  font-weight: 350;
  font-size: 22px;
  letter-spacing: -0.01em;
  color: var(--paper);
}
.kc-locale {
  display: flex;
  gap: var(--space-3);
  font-family: 'JetBrains Mono', monospace;
  font-size: 10.5px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}
.kc-locale-link { color: var(--paper-dim); }
.kc-locale-link.is-current { color: var(--paper); }

/* ---------- Stage (2-col → 1-col) ---------- */
.kc-stage {
  flex: 1;
  display: grid;
  grid-template-columns: 42fr 58fr;
  gap: var(--space-7);
  padding: var(--space-7) var(--space-6);
}
@media (max-width: 720px) {
  .kc-stage {
    grid-template-columns: 1fr;
    gap: var(--space-5);
    padding: var(--space-5) var(--space-4);
  }
}

/* ---------- Voice (manifest gauche) ---------- */
.kc-voice { position: relative; padding-right: var(--space-4); }
.kc-label {
  font-family: 'JetBrains Mono', monospace;
  font-weight: 500;
  font-size: 10.5px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--paper-dim);
  margin-bottom: var(--space-5);
}
.kc-lines { display: flex; flex-direction: column; gap: var(--space-2); }
.kc-line {
  margin: 0;
  font-family: 'Fraunces', serif;
  font-style: italic;
  font-size: 16px;
  line-height: 1.4;
  color: var(--paper);
}
.kc-line.is-pending { opacity: 0; }
.kc-line.is-done::after {
  content: '';
  display: inline-block;
  width: 0.5em;
  height: 1em;
  background: var(--signal);
  vertical-align: -0.1em;
  margin-left: 2px;
  animation: kc-blink 1s steps(2) infinite;
}
.kc-line-aside {
  font-size: 14px;
  color: var(--paper-soft);
  margin-top: var(--space-5);
}
@keyframes kc-blink { 50% { opacity: 0; } }

@media (max-width: 720px) {
  .kc-voice { padding-right: 0; }
  .kc-voice .kc-line:nth-child(n+3) { display: none; } /* on garde 2 lignes max */
}

/* ---------- Terminal-card (décor login + login-otp) ---------- */
.kc-terminal-card {
  position: absolute;
  right: var(--space-5);
  bottom: 0;
  width: 42%;
  aspect-ratio: 0.85;
  background: var(--paper);
  color: var(--ink);
  border: 1px solid var(--ink);
  box-shadow: 6px 6px 0 var(--signal);
  padding: var(--space-3);
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}
.kc-terminal-card .kc-terminal-label {
  font-family: 'JetBrains Mono', monospace;
  font-size: 8px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--signal);
}
@media (max-width: 720px) { .kc-terminal-card { display: none; } }

/* ---------- Form ---------- */
.kc-form { display: flex; flex-direction: column; gap: var(--space-4); max-width: 360px; }
.kc-form label {
  display: block;
  font-family: 'JetBrains Mono', monospace;
  font-size: 10.5px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--paper-dim);
  margin-bottom: var(--space-1);
}
.kc-form input[type="text"],
.kc-form input[type="email"],
.kc-form input[type="password"] {
  width: 100%;
  background: var(--field-bg);
  color: var(--paper);
  border: none;
  border-bottom: 1px solid var(--field-line);
  padding: var(--space-2) 0;
  font-family: 'JetBrains Mono', monospace;
  font-size: 14px;
  outline: none;
  transition: border-color var(--dur) var(--ease);
}
.kc-form input:focus { border-bottom-color: var(--field-line-active); }
.kc-form .kc-error {
  font-family: 'JetBrains Mono', monospace;
  font-size: 10.5px;
  letter-spacing: 0.12em;
  color: var(--signal);
  margin-top: var(--space-1);
}
.kc-form .kc-checkbox {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  color: var(--paper-soft);
}
.kc-form .kc-checkbox input { accent-color: var(--signal); }
.kc-form button[type="submit"] {
  background: var(--signal);
  color: var(--ink);
  border: none;
  padding: var(--space-3) var(--space-5);
  font-family: 'JetBrains Mono', monospace;
  font-weight: 500;
  font-size: 12px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  cursor: pointer;
  transition: filter var(--dur) var(--ease);
}
.kc-form button[type="submit"]:hover { filter: brightness(1.1); }
.kc-form button[type="submit"]:focus-visible { outline: 2px solid var(--paper); outline-offset: 2px; }
.kc-form .kc-aux {
  display: flex;
  justify-content: space-between;
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  color: var(--paper-soft);
}

/* ---------- Divider ---------- */
.kc-divider {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  font-family: 'JetBrains Mono', monospace;
  font-size: 10.5px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--paper-dim);
  margin: var(--space-3) 0;
}
.kc-divider::before, .kc-divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--rule);
}

/* ---------- Social buttons ---------- */
.kc-social { display: flex; flex-direction: column; gap: var(--space-2); }
.kc-social-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
  border: 1px solid var(--rule);
  background: transparent;
  color: var(--paper);
  padding: var(--space-3) var(--space-4);
  transition: border-color var(--dur) var(--ease), color var(--dur) var(--ease);
}
.kc-social-btn:hover { border-color: var(--signal); color: var(--signal); }
.kc-social-glyph { display: inline-flex; width: 18px; height: 18px; }
.kc-social-label {
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  letter-spacing: 0.10em;
}

/* ---------- Footer ---------- */
.kc-foot {
  display: flex;
  justify-content: space-between;
  padding: var(--space-4) var(--space-6);
  border-top: 1px solid var(--rule);
  font-family: 'JetBrains Mono', monospace;
  font-size: 10.5px;
  letter-spacing: 0.10em;
  color: var(--paper-dim);
}
.kc-foot a { color: var(--paper-dim); }
.kc-foot a:hover { color: var(--signal); }
@media (max-width: 720px) {
  .kc-foot { padding: var(--space-3) var(--space-4); font-size: 10px; }
}

/* ---------- Reduced motion ---------- */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation: none !important;
    transition: none !important;
  }
  .kc-line.is-pending { opacity: 1 !important; }
  .kc-line.is-done::after { animation: none !important; }
}
```

- [ ] **Step 2: Test syntaxique CSS rapide**

Run:
```bash
cat E:/srcs/security/keycloak/Theme/agflow-confident/login/resources/css/styles.css | head -5
wc -l E:/srcs/security/keycloak/Theme/agflow-confident/login/resources/css/styles.css
```

Expected: header de commentaire visible, ~250-280 lignes.

- [ ] **Step 3: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/login/resources/css/styles.css
git commit -m "feat(theme): tokens + layout + composants CSS"
```

---

## Task 5: `template.ftl` + macro `voice`

**Files:**
- Create: `Theme/agflow-confident/login/template.ftl`

- [ ] **Step 1: Écrire le template**

Create `Theme/agflow-confident/login/template.ftl` :

```ftl
<#import "_macros-maillage.ftl" as maillage>
<#macro registrationLayout bodyClass="" displayMessage=true displayRequiredFields=false displayWide=false showAnotherWayIfPresent=true voiceScreen="login" showGoogleLine=false>
<!DOCTYPE html>
<html lang="${locale.currentLanguageTag!'fr'}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${(realm.displayNameHtml!realm.displayName!realm.name)} — ${msg("loginTitle")}</title>
  <link rel="icon" href="${url.resourcesPath}/img/favicon.svg" type="image/svg+xml">
  <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body class="kc-body ${bodyClass}">

  <header class="kc-head">
    <a class="kc-brand" href="${url.loginUrl}">${realm.displayName!"yoops"}</a>
    <#if realm.internationalizationEnabled && (locale.supported?size > 1)>
      <nav class="kc-locale">
        <#list locale.supported as l>
          <a class="kc-locale-link <#if l.languageTag == locale.currentLanguageTag>is-current</#if>"
             href="${l.url}">${l.languageTag}</a>
        </#list>
      </nav>
    </#if>
  </header>

  <main class="kc-stage">
    <@maillage.voice screen=voiceScreen showGoogleLine=showGoogleLine/>
    <section class="kc-form">
      <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
        <div class="kc-error" data-message-type="${message.type}">${kcSanitize(message.summary)?no_esc}</div>
      </#if>
      <#nested "form">
      <#if displayRequiredFields>
        <p class="kc-aux"><small>${msg("requiredFields")}</small></p>
      </#if>
    </section>
  </main>

  <footer class="kc-foot">
    <span>© ${.now?string('yyyy')} ${realm.displayName!"yoops"}</span>
    <span>
      <a href="/privacy">${msg("legal.privacy")}</a>
      &nbsp;·&nbsp;
      <a href="/terms">${msg("legal.terms")}</a>
    </span>
  </footer>

  <script src="${url.resourcesPath}/js/maillage.js" defer></script>
</body>
</html>
</#macro>
```

- [ ] **Step 2: Écrire la macro `voice` dans un fichier séparé**

Create `Theme/agflow-confident/login/_macros-maillage.ftl` :

```ftl
<#--
  Macro qui rend la colonne gauche "voix du maillage" pour un écran donné.
  Lit les clés maillage.<screen>.label et maillage.<screen>.line1..4 dans messages_<lang>.properties.
-->
<#macro voice screen showGoogleLine=false>
<aside class="kc-voice" data-screen="${screen}">
  <div class="kc-label">${msg("maillage." + screen + ".label")}</div>
  <div class="kc-lines">
    <#list 1..4 as i>
      <#assign key = "maillage." + screen + ".line" + i>
      <#assign val = msg(key)>
      <#if val?length gt 0 && val != key>
        <p class="kc-line is-pending" data-text="${val}"></p>
      </#if>
    </#list>
  </div>
  <#if showGoogleLine>
    <#assign gKey = "maillage." + screen + ".line_google">
    <#assign gVal = msg(gKey)>
    <#if gVal?length gt 0 && gVal != gKey>
      <p class="kc-line kc-line-aside">${gVal}</p>
    </#if>
  </#if>
  <#if screen == "login" || screen == "login-otp">
    <div class="kc-terminal-card" aria-hidden="true">
      <span class="kc-terminal-label">access</span>
    </div>
  </#if>
</aside>
</#macro>
```

- [ ] **Step 3: Créer le favicon SVG**

Create `Theme/agflow-confident/login/resources/img/favicon.svg` :

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" fill="#0d0e10"/>
  <circle cx="16" cy="16" r="6" fill="none" stroke="#ff5b1f" stroke-width="1.5"/>
  <circle cx="16" cy="16" r="2" fill="#ff5b1f"/>
</svg>
```

- [ ] **Step 4: Créer le glyph Google SVG (inclus comme FTL)**

Create `Theme/agflow-confident/login/resources/img/social-google.svg.ftl` :

```ftl
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18" fill="currentColor" aria-hidden="true">
  <path d="M12.48 10.92v3.28h7.84c-.24 1.84-.853 3.187-1.787 4.133-1.147 1.147-2.933 2.4-6.053 2.4-4.827 0-8.6-3.893-8.6-8.72s3.773-8.72 8.6-8.72c2.6 0 4.507 1.027 5.907 2.347l2.307-2.307C18.747 1.44 16.133 0 12.48 0 5.867 0 .307 5.387.307 12s5.56 12 12.173 12c3.573 0 6.267-1.173 8.373-3.36 2.16-2.16 2.84-5.213 2.84-7.667 0-.76-.053-1.467-.173-2.053H12.48z"/>
</svg>
```

- [ ] **Step 5: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/login/template.ftl Theme/agflow-confident/login/_macros-maillage.ftl Theme/agflow-confident/login/resources/img/
git commit -m "feat(theme): layout 2-col + voice macro + assets"
```

---

## Task 6: `login.ftl` + `maillage.js` + messages clés pour login

**Files:**
- Create: `Theme/agflow-confident/login/login.ftl`
- Modify: `Theme/agflow-confident/login/resources/js/maillage.js` (remplacement intégral)
- Create: `Theme/agflow-confident/login/messages/messages_fr.properties` (clés minimales pour login)
- Create: `Theme/agflow-confident/login/messages/messages_en.properties` (idem EN)

- [ ] **Step 1: Écrire `login.ftl`**

Create `Theme/agflow-confident/login/login.ftl` :

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') voiceScreen="login" showGoogleLine=(social?? && social.providers?has_content); section>

  <form id="kc-form-login" action="${url.loginAction}" method="post" novalidate="novalidate">

    <div class="kc-field">
      <label for="username">${msg("usernameOrEmail")}</label>
      <input id="username"
             name="username"
             type="email"
             autocomplete="username"
             autofocus
             value="${(login.username!'')}"
             aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
      <#if messagesPerField.existsError('username','password')>
        <span class="kc-error" aria-live="polite">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
      </#if>
    </div>

    <div class="kc-field">
      <label for="password">${msg("password")}</label>
      <input id="password" name="password" type="password" autocomplete="current-password"/>
    </div>

    <div class="kc-form-options">
      <#if realm.rememberMe && !usernameHidden??>
        <label class="kc-checkbox">
          <input type="checkbox" name="rememberMe" <#if login.rememberMe??>checked</#if>>
          <span>${msg("rememberMe")}</span>
        </label>
      </#if>
      <#if realm.resetPasswordAllowed>
        <a href="${url.loginResetCredentialsUrl}" class="kc-aux-link">${msg("doForgotPassword")}</a>
      </#if>
    </div>

    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>

    <button type="submit" name="login" id="kc-login">${msg("doLogIn")}</button>
  </form>

  <#if realm.password && social?? && social.providers?has_content>
    <div class="kc-divider"><span>${msg("login.or")}</span></div>
    <div class="kc-social">
      <#list social.providers as p>
        <a class="kc-social-btn kc-social-${p.alias}" href="${p.loginUrl}" data-provider="${p.alias}">
          <span class="kc-social-glyph">
            <#include "resources/img/social-${p.alias}.svg.ftl">
          </span>
          <span class="kc-social-label">${msg("login.continueWith", p.displayName!p.alias)}</span>
        </a>
      </#list>
    </div>
  </#if>

</@layout.registrationLayout>
```

- [ ] **Step 2: Écrire `maillage.js` complet**

Remplace tout le contenu de `Theme/agflow-confident/login/resources/js/maillage.js` par :

```js
/* agflow-confident — typewriter one-shot per session, prefers-reduced-motion aware.
   Spec: docs/superpowers/specs/2026-05-19-keycloak-theme-agflow-confident-design.md §6.5–6.6
*/
(function () {
  'use strict';

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function cyrb53(str, seed = 0) {
    let h1 = 0xdeadbeef ^ seed, h2 = 0x41c6ce57 ^ seed;
    for (let i = 0, ch; i < str.length; i++) {
      ch = str.charCodeAt(i);
      h1 = Math.imul(h1 ^ ch, 2654435761);
      h2 = Math.imul(h2 ^ ch, 1597334677);
    }
    h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507) ^ Math.imul(h2 ^ (h2 >>> 13), 3266489909);
    h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507) ^ Math.imul(h1 ^ (h1 >>> 13), 3266489909);
    return (4294967296 * (2097151 & h2) + (h1 >>> 0)).toString(36);
  }

  function buildSeenKey(voiceEl) {
    const screen = voiceEl.getAttribute('data-screen') || 'unknown';
    if (screen === 'error' || screen === 'login-page-expired') {
      const msgEl = document.querySelector('[data-message-type]');
      const seed = msgEl ? msgEl.textContent.trim() : '';
      return 'agflow_confident.seen.' + screen + '.' + cyrb53(seed);
    }
    return 'agflow_confident.seen.' + screen;
  }

  function revealStatic(voiceEl) {
    voiceEl.querySelectorAll('.kc-line.is-pending').forEach((line) => {
      line.textContent = line.getAttribute('data-text') || '';
      line.classList.remove('is-pending');
    });
    const lines = voiceEl.querySelectorAll('.kc-line:not(.kc-line-aside)');
    if (lines.length > 0) lines[lines.length - 1].classList.add('is-done');
  }

  function typewrite(voiceEl, onDone) {
    const lines = Array.from(voiceEl.querySelectorAll('.kc-line.is-pending'));
    let idx = 0;

    function typeOne() {
      if (idx >= lines.length) { onDone(); return; }
      const line = lines[idx];
      const text = line.getAttribute('data-text') || '';
      line.style.opacity = '1';
      line.classList.remove('is-pending');
      let i = 0;
      const tick = () => {
        line.textContent = text.slice(0, ++i);
        if (i < text.length) {
          setTimeout(tick, 30);
        } else {
          idx++;
          if (idx === lines.length) line.classList.add('is-done');
          setTimeout(typeOne, 400);
        }
      };
      tick();
    }

    typeOne();
  }

  function init() {
    const voiceEl = document.querySelector('.kc-voice[data-screen]');
    if (!voiceEl) return;

    const seenKey = buildSeenKey(voiceEl);
    let alreadySeen = false;
    try { alreadySeen = sessionStorage.getItem(seenKey) === '1'; } catch (_) {}

    if (reducedMotion || alreadySeen) {
      revealStatic(voiceEl);
      return;
    }

    typewrite(voiceEl, () => {
      try { sessionStorage.setItem(seenKey, '1'); } catch (_) {}
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
```

- [ ] **Step 3: Créer `messages_fr.properties` avec les clés pour login + overrides Keycloak essentiels**

Create `Theme/agflow-confident/login/messages/messages_fr.properties` :

```properties
# === Overrides Keycloak ===
loginTitle           = Connexion
usernameOrEmail      = Email
password             = Mot de passe
rememberMe           = Se souvenir de moi
doForgotPassword     = Mot de passe oublié ?
doLogIn              = Entrer
requiredFields       = (requis)
login.or             = ou
login.continueWith   = Continuer avec {0}
legal.privacy        = Confidentialité
legal.terms          = CGU

# === Voix du maillage — login ===
maillage.login.label       = §01 — ACCÈS
maillage.login.line1       = — Bonjour. Tu reviens.
maillage.login.line2       = — J'ai gardé ta place au chaud.
maillage.login.line3       = — Pose ton nom ici ↓
maillage.login.line_google = — Si ton sceau est ailleurs, prends la porte d'à côté.
```

- [ ] **Step 4: Créer `messages_en.properties` minimal pour login**

Create `Theme/agflow-confident/login/messages/messages_en.properties` :

```properties
# === Keycloak overrides ===
loginTitle           = Sign in
usernameOrEmail      = Email
password             = Password
rememberMe           = Remember me
doForgotPassword     = Forgot password?
doLogIn              = Enter
requiredFields       = (required)
login.or             = or
login.continueWith   = Continue with {0}
legal.privacy        = Privacy
legal.terms          = Terms

# === Maillage voice — login ===
maillage.login.label       = §01 — ACCESS
maillage.login.line1       = — Hello. You're back.
maillage.login.line2       = — I kept your place warm.
maillage.login.line3       = — Lay your name here ↓
maillage.login.line_google = — If your seal is elsewhere, take the side door.
```

- [ ] **Step 5: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/login/login.ftl Theme/agflow-confident/login/resources/js/maillage.js Theme/agflow-confident/login/messages/
git commit -m "feat(theme): login.ftl + typewriter JS + fr/en messages (login screen)"
```

---

## Task 7: QA visuelle du login (déploiement temporaire LXC)

**Files:**
- Aucun fichier modifié — uniquement déploiement et vérification.

- [ ] **Step 1: Synchroniser le thème vers le LXC**

Run (depuis Windows, le `pct` se passe sur le host Proxmox accessible en SSH) :

```bash
# Copier l'arbo vers le host Proxmox (adapte l'IP)
scp -r E:/srcs/security/keycloak/Theme/agflow-confident root@<proxmox-host>:/tmp/

# Pousser dans le LXC 210
ssh root@<proxmox-host> "pct push 210 -r /tmp/agflow-confident /opt/keycloak/themes/agflow-confident"
```

Si tu n'as pas configuré l'accès SSH au host Proxmox, alternative :
```bash
# Via rsync direct si le LXC est joignable en SSH
rsync -avz E:/srcs/security/keycloak/Theme/agflow-confident/ root@192.168.10.42:/opt/keycloak/themes/agflow-confident/
```

- [ ] **Step 2: Forcer le mode dev (cache off) sur Keycloak**

```bash
ssh root@192.168.10.42 << 'EOF'
cat > /etc/systemd/system/keycloak.service.d/dev.conf << CONF
[Service]
Environment=KC_SPI_THEME_STATIC_MAX_AGE=-1
Environment=KC_SPI_THEME_CACHE_THEMES=false
Environment=KC_SPI_THEME_CACHE_TEMPLATES=false
CONF
systemctl daemon-reload
systemctl restart keycloak
EOF
```

- [ ] **Step 3: Activer temporairement le thème via l'admin UI**

Va sur `https://auth.yoops.org/admin`, realm `yoops` → Realm Settings → Themes → Login Theme = `agflow-confident`. Save.

(On reviendra activer ça via le JSON en Task 12 ; pour la QA on bascule à la main.)

- [ ] **Step 4: Walk-through manuel — 1ère visite**

Ouvre `https://auth.yoops.org/realms/yoops/protocol/openid-connect/auth?client_id=hitl-console&response_type=code&redirect_uri=http://localhost:5173/&scope=openid` en **navigation privée**.

Vérifie :
- [ ] Layout 2-col visible sur desktop
- [ ] Logo « yoops » en header gauche, locale switcher `fr · en` droite
- [ ] Label `§01 — ACCÈS` en mono
- [ ] 3 lignes du maillage s'écrivent en typewriter, ~30ms/char
- [ ] Caret orange clignote en fin de dernière ligne
- [ ] Champs email/password avec underline-only
- [ ] Bouton « Entrer » orange
- [ ] Divider « ou »
- [ ] Pas encore de bouton Google (l'IdP n'est pas activé) — c'est normal, ce sera testé en Task 12
- [ ] Footer en bas avec © + liens

- [ ] **Step 5: Walk-through manuel — reload**

Reload la page (F5). Vérifie :
- [ ] Les 3 lignes apparaissent **instantanément** (pas de typewriter)
- [ ] sessionStorage contient `agflow_confident.seen.login = "1"` (DevTools → Application → Session Storage)

- [ ] **Step 6: Walk-through manuel — reduced-motion**

DevTools → Rendering → Emulate CSS prefers-reduced-motion = reduce. Reload.

Vérifie :
- [ ] Pas d'animation, lignes statiques
- [ ] Pas de caret clignotant
- [ ] Pas de transitions sur hover

- [ ] **Step 7: Walk-through manuel — JS off**

DevTools → Settings → Debugger → Disable JavaScript. Reload.

Vérifie :
- [ ] Les 3 lignes du maillage sont **présentes** (rendu serveur)
- [ ] Le formulaire reste utilisable
- [ ] Erreur console acceptable (pas d'exception bloquante)

- [ ] **Step 8: Walk-through manuel — mobile**

DevTools → Device Toolbar → iPhone 12 (390x844).

Vérifie :
- [ ] Manifest empilé au-dessus du formulaire
- [ ] Maximum 2 lignes du maillage affichées
- [ ] Pas de terminal-card
- [ ] Pas de scroll horizontal
- [ ] Bouton « Entrer » au-dessus de la ligne de flottaison

- [ ] **Step 9: Walk-through manuel — light mode**

DevTools → Rendering → Emulate CSS prefers-color-scheme = light. Reload (en privée pour reset sessionStorage).

Vérifie :
- [ ] Fond passe en `paper` (#f4ecdc)
- [ ] Texte passe en `ink` (#1a1a1f)
- [ ] Signal orange légèrement plus profond (`#d9430b`)
- [ ] Contraste lisible partout

- [ ] **Step 10: Si tout passe — commit "QA login OK"**

Si un point ne passe pas, revenir en arrière sur les Tasks 4-6 pour corriger AVANT de continuer.

```bash
cd E:/srcs/security/keycloak
git commit --allow-empty -m "test(theme): QA login OK — 1st visit, reload, reduced-motion, JS off, mobile, light"
```

---

## Task 8: Écrans d'erreur — `error.ftl` + `login-page-expired.ftl`

**Files:**
- Create: `Theme/agflow-confident/login/error.ftl`
- Create: `Theme/agflow-confident/login/login-page-expired.ftl`
- Modify: `Theme/agflow-confident/login/messages/messages_fr.properties` (ajout clés)
- Modify: `Theme/agflow-confident/login/messages/messages_en.properties` (ajout clés)

- [ ] **Step 1: Écrire `error.ftl`**

Create `Theme/agflow-confident/login/error.ftl` :

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false voiceScreen="error"; section>
  <div class="kc-error-block">
    <#if message?has_content>
      <p class="kc-error" data-message-type="${message.type!'error'}">${kcSanitize(message.summary)?no_esc}</p>
    </#if>
    <#if client?? && client.baseUrl?has_content>
      <a href="${client.baseUrl}" class="kc-aux-link">${msg("backToApplication")}</a>
    </#if>
  </div>
</@layout.registrationLayout>
```

- [ ] **Step 2: Écrire `login-page-expired.ftl`**

Create `Theme/agflow-confident/login/login-page-expired.ftl` :

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false voiceScreen="login-page-expired"; section>
  <p class="kc-aux">
    <a href="${url.loginRestartFlowUrl}" class="kc-aux-link">${msg("doClickHere")}</a>
    ${msg("loginTimeout")}
  </p>
</@layout.registrationLayout>
```

- [ ] **Step 3: Ajouter les clés FR**

Append à `messages_fr.properties` :
```properties

# === Voix du maillage — erreurs ===
maillage.error.label = §ÉR — INCIDENT
maillage.error.line1 = — Quelque chose a glissé entre nous.
maillage.error.line2 = — Ce n'est pas de ton fait. Réessaie ↓

maillage.login-page-expired.label = §ÉR — INTERROMPU
maillage.login-page-expired.line1 = — La conversation s'est rompue.
maillage.login-page-expired.line2 = — Reprends depuis le début, je t'attends.

# === Overrides Keycloak — erreurs ===
backToApplication = Retour à l'application
doClickHere       = Clique ici
loginTimeout      = pour recommencer.
```

- [ ] **Step 4: Ajouter les clés EN**

Append à `messages_en.properties` :
```properties

# === Maillage voice — errors ===
maillage.error.label = §ER — INCIDENT
maillage.error.line1 = — Something slipped between us.
maillage.error.line2 = — Not your fault. Try again ↓

maillage.login-page-expired.label = §ER — INTERRUPTED
maillage.login-page-expired.line1 = — The conversation broke off.
maillage.login-page-expired.line2 = — Start again, I'm waiting.

# === Keycloak overrides — errors ===
backToApplication = Back to application
doClickHere       = Click here
loginTimeout      = to start over.
```

- [ ] **Step 5: Re-déployer + QA**

Rsync à nouveau le thème (cf. Task 7 step 1) et :

- [ ] Force une erreur : navigue vers `https://auth.yoops.org/realms/yoops/login-actions/authenticate?session_code=invalid` → `error.ftl` doit afficher `§ÉR — INCIDENT` avec ses 2 lignes
- [ ] Laisse la page de login ouverte 30 min, soumets — `login-page-expired.ftl` doit s'afficher
- [ ] Vérifie que le typewriter rejoue sur chaque nouvelle erreur (clé sessionStorage avec hash)

- [ ] **Step 6: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/login/error.ftl Theme/agflow-confident/login/login-page-expired.ftl Theme/agflow-confident/login/messages/
git commit -m "feat(theme): error + page-expired screens"
```

---

## Task 9: Écrans OTP — `login-otp.ftl` + `login-config-totp.ftl`

**Files:**
- Create: `Theme/agflow-confident/login/login-otp.ftl`
- Create: `Theme/agflow-confident/login/login-config-totp.ftl`
- Modify: `Theme/agflow-confident/login/messages/messages_fr.properties`
- Modify: `Theme/agflow-confident/login/messages/messages_en.properties`

- [ ] **Step 1: Écrire `login-otp.ftl`**

Create `Theme/agflow-confident/login/login-otp.ftl` :

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('totp') voiceScreen="login-otp"; section>

  <form id="kc-otp-login-form" action="${url.loginAction}" method="post">

    <#if otpLogin.userOtpCredentials?size gt 1>
      <div class="kc-field">
        <label>${msg("loginOtpDevices")}</label>
        <#list otpLogin.userOtpCredentials as otpCredential>
          <label class="kc-radio">
            <input type="radio" name="selectedCredentialId" value="${otpCredential.id}"
                   <#if otpCredential.id == otpLogin.selectedCredentialId>checked</#if>>
            <span>${otpCredential.userLabel}</span>
          </label>
        </#list>
      </div>
    </#if>

    <div class="kc-field">
      <label for="otp">${msg("loginOtpOneTime")}</label>
      <input id="otp"
             name="otp"
             type="text"
             autocomplete="one-time-code"
             inputmode="numeric"
             pattern="[0-9]*"
             autofocus
             aria-invalid="<#if messagesPerField.existsError('totp')>true</#if>"/>
      <#if messagesPerField.existsError('totp')>
        <span class="kc-error" aria-live="polite">${kcSanitize(messagesPerField.getFirstError('totp'))?no_esc}</span>
      </#if>
    </div>

    <button type="submit" name="login">${msg("doLogIn")}</button>
  </form>

</@layout.registrationLayout>
```

- [ ] **Step 2: Écrire `login-config-totp.ftl`**

Create `Theme/agflow-confident/login/login-config-totp.ftl` :

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('totp','userLabel') voiceScreen="login-config-totp"; section>

  <ol class="kc-totp-steps">
    <li>
      ${msg("loginTotpStep1")}
      <ul class="kc-totp-apps">
        <#list totp.policy.supportedApplications as app>
          <li>${msg(app)}</li>
        </#list>
      </ul>
    </li>
    <li>
      <p>${msg("loginTotpManualStep2")}</p>
      <img src="data:image/png;base64,${totp.totpSecretQrCode}" alt="qr-totp" class="kc-qr"/>
      <p class="kc-aux-mono">${msg("loginTotpManualStep3")} <code>${totp.totpSecretEncoded}</code></p>
    </li>
    <li>
      <form action="${url.loginAction}" method="post" id="kc-totp-settings-form">
        <input type="hidden" name="totpSecret" value="${totp.totpSecret}"/>

        <div class="kc-field">
          <label for="totp">${msg("authenticatorCode")}</label>
          <input id="totp" name="totp" type="text" inputmode="numeric" autocomplete="off"
                 aria-invalid="<#if messagesPerField.existsError('totp')>true</#if>"/>
          <#if messagesPerField.existsError('totp')>
            <span class="kc-error">${kcSanitize(messagesPerField.getFirstError('totp'))?no_esc}</span>
          </#if>
        </div>

        <div class="kc-field">
          <label for="userLabel">${msg("loginTotpDeviceName")}</label>
          <input id="userLabel" name="userLabel" type="text" autocomplete="off"/>
        </div>

        <button type="submit">${msg("doSubmit")}</button>
      </form>
    </li>
  </ol>

</@layout.registrationLayout>
```

- [ ] **Step 3: Ajouter les clés OTP en FR**

Append à `messages_fr.properties` :
```properties

# === Voix du maillage — OTP ===
maillage.login-otp.label = §01.5 — VÉRIFIER
maillage.login-otp.line1 = — Encore un signe.
maillage.login-otp.line2 = — Le code qu'on t'a envoyé, ici. ↓

maillage.login-config-totp.label = §00.5 — APPAREILLAGE
maillage.login-config-totp.line1 = — Lions ton téléphone à mon souvenir.
maillage.login-config-totp.line2 = — Scanne le motif, je le reconnaîtrai après.

# === Overrides Keycloak — OTP ===
loginOtpOneTime      = Code à usage unique
loginOtpDevices      = Appareil
loginTotpStep1       = Installe une de ces applis sur ton téléphone
loginTotpManualStep2 = Scanne ce code
loginTotpManualStep3 = Ou entre la clé :
authenticatorCode    = Code de l'application
loginTotpDeviceName  = Nom de l'appareil
doSubmit             = Valider
```

- [ ] **Step 4: Ajouter les clés OTP en EN**

Append à `messages_en.properties` :
```properties

# === Maillage voice — OTP ===
maillage.login-otp.label = §01.5 — VERIFY
maillage.login-otp.line1 = — Another sign.
maillage.login-otp.line2 = — The code we sent you, here. ↓

maillage.login-config-totp.label = §00.5 — PAIRING
maillage.login-config-totp.line1 = — Let's bind your phone to my memory.
maillage.login-config-totp.line2 = — Scan the pattern, I'll know it later.

# === Keycloak overrides — OTP ===
loginOtpOneTime      = One-time code
loginOtpDevices      = Device
loginTotpStep1       = Install one of these apps on your phone
loginTotpManualStep2 = Scan this code
loginTotpManualStep3 = Or enter the key:
authenticatorCode    = App code
loginTotpDeviceName  = Device name
doSubmit             = Submit
```

- [ ] **Step 5: Ajouter les styles QR + steps dans `styles.css`**

Append à `Theme/agflow-confident/login/resources/css/styles.css` :

```css

/* ---------- TOTP steps ---------- */
.kc-totp-steps {
  list-style: none;
  counter-reset: tstep;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}
.kc-totp-steps > li {
  counter-increment: tstep;
  position: relative;
  padding-left: var(--space-6);
}
.kc-totp-steps > li::before {
  content: counter(tstep, decimal-leading-zero);
  position: absolute;
  left: 0;
  top: 0;
  font-family: 'JetBrains Mono', monospace;
  font-size: 10.5px;
  letter-spacing: 0.18em;
  color: var(--signal);
}
.kc-totp-apps { list-style: '— '; padding-left: var(--space-4); margin-top: var(--space-2); color: var(--paper-soft); }
.kc-qr { display: block; margin: var(--space-3) 0; max-width: 180px; image-rendering: pixelated; background: var(--paper); padding: var(--space-2); }
.kc-aux-mono { font-family: 'JetBrains Mono', monospace; font-size: 11px; color: var(--paper-soft); }
.kc-radio { display: block; margin-bottom: var(--space-2); font-family: 'JetBrains Mono', monospace; font-size: 12px; }
```

- [ ] **Step 6: Re-déployer et QA**

Déclenche le flow OTP (en configurant un OTP sur ton compte test, ou via `kcadm.sh`) :

- [ ] `login-otp.ftl` rend avec label `§01.5 — VÉRIFIER`
- [ ] Terminal-card présente (login-otp est dans la liste, cf. §5.4)
- [ ] `login-config-totp.ftl` rend avec QR code + champ code + champ device name
- [ ] Steps numérotés visibles

- [ ] **Step 7: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/login/login-otp.ftl Theme/agflow-confident/login/login-config-totp.ftl Theme/agflow-confident/login/messages/ Theme/agflow-confident/login/resources/css/styles.css
git commit -m "feat(theme): OTP + TOTP config screens"
```

---

## Task 10: Trio mot de passe — reset + update + verify-email

**Files:**
- Create: `Theme/agflow-confident/login/login-reset-password.ftl`
- Create: `Theme/agflow-confident/login/login-update-password.ftl`
- Create: `Theme/agflow-confident/login/login-verify-email.ftl`
- Modify: `Theme/agflow-confident/login/messages/messages_fr.properties`
- Modify: `Theme/agflow-confident/login/messages/messages_en.properties`

- [ ] **Step 1: Écrire `login-reset-password.ftl`**

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username') voiceScreen="login-reset-password"; section>

  <form id="kc-reset-password-form" action="${url.loginAction}" method="post">
    <div class="kc-field">
      <label for="username">${msg("usernameOrEmail")}</label>
      <input id="username"
             name="username"
             type="email"
             autocomplete="username"
             autofocus
             value="${(auth.attemptedUsername!'')}"
             aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"/>
      <#if messagesPerField.existsError('username')>
        <span class="kc-error">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
      </#if>
    </div>

    <button type="submit">${msg("doSubmit")}</button>

    <p class="kc-aux">
      <a href="${url.loginUrl}" class="kc-aux-link">${msg("backToLogin")}</a>
    </p>
  </form>

</@layout.registrationLayout>
```

- [ ] **Step 2: Écrire `login-update-password.ftl`**

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-confirm') voiceScreen="login-update-password"; section>

  <form id="kc-passwd-update-form" action="${url.loginAction}" method="post">
    <input type="text" id="username" name="username" value="${username}" autocomplete="username" readonly hidden/>
    <input type="password" id="password" name="password" autocomplete="current-password" hidden/>

    <div class="kc-field">
      <label for="password-new">${msg("passwordNew")}</label>
      <input id="password-new" name="password-new" type="password" autocomplete="new-password" autofocus
             aria-invalid="<#if messagesPerField.existsError('password')>true</#if>"/>
      <#if messagesPerField.existsError('password')>
        <span class="kc-error">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
      </#if>
    </div>

    <div class="kc-field">
      <label for="password-confirm">${msg("passwordConfirm")}</label>
      <input id="password-confirm" name="password-confirm" type="password" autocomplete="new-password"
             aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>"/>
      <#if messagesPerField.existsError('password-confirm')>
        <span class="kc-error">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</span>
      </#if>
    </div>

    <button type="submit">${msg("doSubmit")}</button>
  </form>

</@layout.registrationLayout>
```

- [ ] **Step 3: Écrire `login-verify-email.ftl`**

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false voiceScreen="login-verify-email"; section>
  <p class="kc-body-copy">${msg("emailVerifyInstruction1", user.email!'?')}</p>
  <p class="kc-aux">
    ${msg("emailVerifyInstruction2")}
    <a href="${url.loginAction}" class="kc-aux-link">${msg("doClickHere")}</a>
    ${msg("emailVerifyInstruction3")}
  </p>
</@layout.registrationLayout>
```

- [ ] **Step 4: Ajouter les clés FR**

Append à `messages_fr.properties` :
```properties

# === Voix du maillage — passwords + verify ===
maillage.login-reset-password.label = §02 — MÉMOIRE
maillage.login-reset-password.line1 = — Tu as perdu le sceau.
maillage.login-reset-password.line2 = — Donne-moi l'adresse, je t'envoie une nouvelle clef.

maillage.login-update-password.label = §03 — RENOUVEAU
maillage.login-update-password.line1 = — On efface l'ancien sceau.
maillage.login-update-password.line2 = — Choisis-en un que tu retiendras.
maillage.login-update-password.line3 = — Je n'en garde aucune trace.

maillage.login-verify-email.label = §02 — ATTENTE
maillage.login-verify-email.line1 = — Je viens de t'envoyer un mot.
maillage.login-verify-email.line2 = — Ouvre-le pour que je sache que c'est bien toi.

# === Overrides Keycloak — passwords + verify ===
passwordNew          = Nouveau mot de passe
passwordConfirm      = Confirmation
backToLogin          = Retour à la connexion
emailVerifyInstruction1 = Un email de vérification a été envoyé à {0}.
emailVerifyInstruction2 = Tu n'as rien reçu ?
emailVerifyInstruction3 = pour renvoyer le mail.
```

- [ ] **Step 5: Ajouter les clés EN**

Append à `messages_en.properties` :
```properties

# === Maillage voice — passwords + verify ===
maillage.login-reset-password.label = §02 — MEMORY
maillage.login-reset-password.line1 = — You lost the seal.
maillage.login-reset-password.line2 = — Give me the address, I'll send a new key.

maillage.login-update-password.label = §03 — RENEWAL
maillage.login-update-password.line1 = — We erase the old seal.
maillage.login-update-password.line2 = — Choose one you'll remember.
maillage.login-update-password.line3 = — I keep no trace of it.

maillage.login-verify-email.label = §02 — WAITING
maillage.login-verify-email.line1 = — I just sent you a word.
maillage.login-verify-email.line2 = — Open it so I know it's really you.

# === Keycloak overrides — passwords + verify ===
passwordNew          = New password
passwordConfirm      = Confirm
backToLogin          = Back to sign in
emailVerifyInstruction1 = A verification email was sent to {0}.
emailVerifyInstruction2 = Didn't receive anything?
emailVerifyInstruction3 = to resend the email.
```

- [ ] **Step 6: Re-déployer et QA**

- [ ] Sur le login, clique « Mot de passe oublié » → `login-reset-password.ftl` avec `§02 — MÉMOIRE`
- [ ] Force le `Required Action: Update Password` sur un user → `login-update-password.ftl` avec `§03 — RENOUVEAU`
- [ ] Force `Required Action: Verify Email` → `login-verify-email.ftl` avec `§02 — ATTENTE`

- [ ] **Step 7: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/login/login-reset-password.ftl Theme/agflow-confident/login/login-update-password.ftl Theme/agflow-confident/login/login-verify-email.ftl Theme/agflow-confident/login/messages/
git commit -m "feat(theme): password reset/update + verify-email screens"
```

---

## Task 11: Écrans calmes — `terms.ftl` + `info.ftl`

**Files:**
- Create: `Theme/agflow-confident/login/terms.ftl`
- Create: `Theme/agflow-confident/login/info.ftl`
- Modify: `Theme/agflow-confident/login/messages/messages_fr.properties`
- Modify: `Theme/agflow-confident/login/messages/messages_en.properties`

- [ ] **Step 1: Écrire `terms.ftl`**

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false voiceScreen="terms"; section>
  <article class="kc-prose">${msg("termsText")?no_esc}</article>

  <form action="${url.loginAction}" method="post">
    <div class="kc-actions-row">
      <button type="submit" name="accept">${msg("doAccept")}</button>
      <button type="submit" name="cancel" class="kc-btn-secondary">${msg("doDecline")}</button>
    </div>
  </form>
</@layout.registrationLayout>
```

- [ ] **Step 2: Écrire `info.ftl`**

```ftl
<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false voiceScreen="info"; section>
  <#if message?has_content>
    <p class="kc-body-copy">${kcSanitize(message.summary)?no_esc}</p>
  </#if>
  <#if pageRedirectUri?has_content>
    <p class="kc-aux"><a href="${pageRedirectUri}" class="kc-aux-link">${msg("backToApplication")}</a></p>
  <#elseif actionUri?has_content>
    <p class="kc-aux"><a href="${actionUri}" class="kc-aux-link">${msg("proceedWithAction")}</a></p>
  <#elseif client.baseUrl?has_content>
    <p class="kc-aux"><a href="${client.baseUrl}" class="kc-aux-link">${msg("backToApplication")}</a></p>
  </#if>
</@layout.registrationLayout>
```

- [ ] **Step 3: Ajouter les clés FR**

Append à `messages_fr.properties` :
```properties

# === Voix du maillage — terms + info ===
maillage.terms.label = §00 — PACTE
maillage.terms.line1 = — Avant d'entrer, lis ce que nous nous devons.
maillage.terms.line2 = — Si tu acceptes, je le saurai.

maillage.info.label = §FIN — RETOUR
maillage.info.line1 = — C'est fait.
maillage.info.line2 = — Tu peux revenir quand tu veux.

# === Overrides Keycloak — terms + info ===
doAccept           = J'accepte
doDecline          = Refuser
proceedWithAction  = Continuer
termsText          = (À remplacer par le texte des CGU yoops.)
```

- [ ] **Step 4: Ajouter les clés EN**

Append à `messages_en.properties` :
```properties

# === Maillage voice — terms + info ===
maillage.terms.label = §00 — PACT
maillage.terms.line1 = — Before you enter, read what we owe each other.
maillage.terms.line2 = — If you accept, I'll know.

maillage.info.label = §END — RETURN
maillage.info.line1 = — Done.
maillage.info.line2 = — Come back anytime.

# === Keycloak overrides — terms + info ===
doAccept           = I accept
doDecline          = Decline
proceedWithAction  = Continue
termsText          = (Replace with the yoops Terms of Service.)
```

- [ ] **Step 5: Ajouter les styles prose + actions-row**

Append à `Theme/agflow-confident/login/resources/css/styles.css` :

```css

/* ---------- Prose (CGU) ---------- */
.kc-prose {
  font-family: 'Fraunces', serif;
  font-size: 15px;
  line-height: 1.6;
  color: var(--paper);
  max-width: 60ch;
  margin-bottom: var(--space-5);
}
.kc-body-copy {
  font-family: 'Fraunces', serif;
  font-size: 15px;
  line-height: 1.6;
  color: var(--paper);
  margin: 0 0 var(--space-3);
}
.kc-actions-row {
  display: flex;
  gap: var(--space-3);
  align-items: center;
}
.kc-btn-secondary {
  background: transparent;
  color: var(--paper-soft);
  border: 1px solid var(--rule);
  padding: var(--space-3) var(--space-5);
  font-family: 'JetBrains Mono', monospace;
  font-weight: 500;
  font-size: 12px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  cursor: pointer;
}
.kc-btn-secondary:hover { border-color: var(--signal); color: var(--signal); }
```

- [ ] **Step 6: Re-déployer et QA**

- [ ] Force `Required Action: Terms and Conditions` → `terms.ftl` avec `§00 — PACTE` et deux boutons
- [ ] Termine un flow auth (par ex. après reset password) → `info.ftl` avec `§FIN — RETOUR`

- [ ] **Step 7: Commit**

```bash
cd E:/srcs/security/keycloak
git add Theme/agflow-confident/login/terms.ftl Theme/agflow-confident/login/info.ftl Theme/agflow-confident/login/messages/ Theme/agflow-confident/login/resources/css/styles.css
git commit -m "feat(theme): terms + info screens"
```

---

## Task 12: Activer Google IdP dans `yoops-realm.json` + étendre `03-apply-realm.sh`

**Files:**
- Modify: `yoops-realm.json`
- Modify: `03-apply-realm.sh`

- [ ] **Step 1: Lire l'état actuel des deux fichiers**

Run :
```bash
cat E:/srcs/security/keycloak/03-apply-realm.sh
```

Note les valeurs actuelles pour ne pas casser l'idempotence.

- [ ] **Step 2: Modifier `yoops-realm.json` — `loginTheme` et bloc `identityProviders`**

Dans `yoops-realm.json` :

Remplace `"loginTheme": "keycloak.v2"` par `"loginTheme": "agflow-confident"`.

Ajoute juste avant le bloc `"smtpServer"` :

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
],
```

(Attention à la virgule de séparation : `identityProviders` se place entre `clients` et `smtpServer`.)

- [ ] **Step 3: Étendre `03-apply-realm.sh` pour exporter les variables Google**

Insère, **avant** l'appel à `kc.sh import` (ou équivalent), le bloc :

```bash
# === Google IdP — extract client_id / client_secret depuis le JSON déposé hors git ===
GOOGLE_JSON_GLOB="${GOOGLE_CLIENT_SECRET_FILE:-/root/keycloak/client_secret_*.json}"
if compgen -G "$GOOGLE_JSON_GLOB" > /dev/null; then
  GOOGLE_JSON=$(ls $GOOGLE_JSON_GLOB | head -1)
  echo "Google IdP : lecture des credentials depuis $GOOGLE_JSON"
  export GOOGLE_CLIENT_ID=$(jq -r '.web.client_id // .installed.client_id' "$GOOGLE_JSON")
  export GOOGLE_CLIENT_SECRET=$(jq -r '.web.client_secret // .installed.client_secret' "$GOOGLE_JSON")
  if [[ -z "$GOOGLE_CLIENT_ID" || -z "$GOOGLE_CLIENT_SECRET" ]]; then
    echo "ERREUR: impossible d'extraire client_id ou client_secret depuis $GOOGLE_JSON" >&2
    exit 1
  fi
else
  echo "WARN: aucun fichier $GOOGLE_JSON_GLOB trouvé — l'IdP Google ne pourra pas s'authentifier." >&2
  echo "       Dépose le JSON OAuth Google dans /root/keycloak/ avant de relancer ce script." >&2
fi
```

- [ ] **Step 4: Vérifier que `jq` est dispo dans le LXC**

Add (ou vérifie présence dans `02-install-keycloak.sh`) que `jq` est installé. Si absent du script existant, ajoute à la phase apt-install :
```bash
apt-get install -y jq
```

- [ ] **Step 5: Commit**

```bash
cd E:/srcs/security/keycloak
git add yoops-realm.json 03-apply-realm.sh 02-install-keycloak.sh
git commit -m "feat(realm): activer agflow-confident + Google IdP via env substitution"
```

---

## Task 13: Déploiement final LXC + QA end-to-end

**Files:**
- Aucun fichier modifié — uniquement déploiement et tests.

- [ ] **Step 1: Pousser le client_secret Google (rotaté en Task 1) sur le LXC**

```bash
# Depuis Windows
scp E:/srcs/security/_secrets/client_secret_google_yoops.json root@<proxmox-host>:/tmp/

# Sur Proxmox
ssh root@<proxmox-host> 'pct push 210 /tmp/client_secret_google_yoops.json /root/keycloak/client_secret_google_yoops.json'
ssh root@<proxmox-host> 'rm /tmp/client_secret_google_yoops.json'
```

- [ ] **Step 2: Pousser le realm JSON et le script à jour**

```bash
scp E:/srcs/security/keycloak/yoops-realm.json E:/srcs/security/keycloak/03-apply-realm.sh root@<proxmox-host>:/tmp/
ssh root@<proxmox-host> '
  pct push 210 /tmp/yoops-realm.json /root/yoops-realm.json
  pct push 210 /tmp/03-apply-realm.sh /root/03-apply-realm.sh
  rm /tmp/yoops-realm.json /tmp/03-apply-realm.sh
'
```

- [ ] **Step 3: Re-pousser le thème final**

```bash
ssh root@<proxmox-host> 'pct exec 210 -- rm -rf /opt/keycloak/themes/agflow-confident'
rsync -avz E:/srcs/security/keycloak/Theme/agflow-confident/ root@192.168.10.42:/opt/keycloak/themes/agflow-confident/
```

- [ ] **Step 4: Désactiver le mode dev (cache template ON) et appliquer le realm**

```bash
ssh root@192.168.10.42 << 'EOF'
rm -f /etc/systemd/system/keycloak.service.d/dev.conf
systemctl daemon-reload
sudo -u keycloak /opt/keycloak/bin/kc.sh build
bash /root/03-apply-realm.sh
systemctl restart keycloak
journalctl -u keycloak -f --since "30 seconds ago" | head -50
EOF
```

Expected: logs Keycloak sans `ERROR`, realm importé, IdP Google présent.

- [ ] **Step 5: QA finale — matrice complète**

Pour chaque écran de la liste, vérifie : rendu correct, voix présente, locale switch, dark + light, mobile (DevTools), JS off (au moins login + error).

| Écran | Comment le déclencher |
|---|---|
| login | Navigue vers `https://auth.yoops.org/realms/yoops/account` non authentifié |
| login + Google | Sur login, vérifie que le bouton « Continuer avec Google » est présent |
| login-reset-password | Clique « Mot de passe oublié » |
| login-update-password | Active `Required Action: Update Password` sur un user test |
| login-verify-email | Crée un user sans `emailVerified` |
| login-page-expired | Laisse la page login ouverte > `accessCodeLifespanLogin` (30 min) puis submit |
| error | Navigue vers une URL d'auth invalide |
| terms | Active `Required Action: Terms and Conditions` |
| login-otp | Configure un OTP sur un user puis logue-toi |
| login-config-totp | Active `Required Action: Configure OTP` |
| info | Termine un flow auth (par ex. après reset password) |

- [ ] **Step 6: End-to-end Google login**

Depuis un navigateur en privée :
- [ ] Clique « Continuer avec Google »
- [ ] Sélectionne un compte Google
- [ ] Accepte les scopes
- [ ] Reviens sur `https://auth.yoops.org/...` → arrive sur l'app (hitl-console) ou sur `idp-review-user-profile.ftl` Keycloak natif (cosmétique en v1, cf. spec §7.6)
- [ ] Vérifie que le user a été créé : `kcadm.sh get users -r yoops -q email=<gmail>`

- [ ] **Step 7: Brute-force**

- [ ] Sur login, soumets 5 fois avec un mauvais mot de passe
- [ ] À la 6e tentative, l'écran error.ftl s'affiche avec le label `§ÉR — INCIDENT` et le message Keycloak « Compte temporairement bloqué »

- [ ] **Step 8: Vérifier `git log` propre**

Run :
```bash
cd E:/srcs/security/keycloak
git log --all --full-history -- 'client_secret_*.json' 2>&1 | head -5
```

Expected: **aucune ligne** — l'ancien fichier ne doit apparaître dans aucun commit.

(Si la rotation Task 1 a été faite avant le premier `git init`, c'est garanti — sinon, il faut `git filter-repo`.)

- [ ] **Step 9: Commit final de QA**

```bash
cd E:/srcs/security/keycloak
git commit --allow-empty -m "test(theme): QA end-to-end OK — funnel complet, Google login, brute-force"
```

---

## Self-Review

**1. Couverture spec → tasks**

| Section spec | Task(s) couvrant |
|---|---|
| §3 Architecture (arbo + héritage + activation) | T2, T5, T12 |
| §3.4 Polices self-hostées | T3 |
| §4 Tokens + typo + rythme | T4 |
| §5 Anatomie page (layout, mobile, composants) | T4, T5 |
| §6.1–6.4 Voix par écran + i18n | T6, T8, T9, T10, T11 |
| §6.5 Mécanique typewriter + sessionStorage | T6 (JS) |
| §6.6 Cas erreur — flag avec errorKey | T6 (JS) + T8 (test) |
| §7.1 Déclaration IdP Google | T12 |
| §7.2 Secret Google rotation + gitignore | T1 |
| §7.3 Extension `03-apply-realm.sh` | T12 |
| §7.4 Rendu bouton social | T6 (login.ftl) + T5 (glyph SVG) |
| §7.5 Ordre vertical formulaire | T6 (login.ftl) |
| §7.6 Trou `idp-review-user-profile` | Hors plan (assumé v1) |
| §8 Hors v1 | Plan ne touche pas account/email/admin themes, ni register |
| §9 Plan livraison | T1 → T13 |
| §10 Critères de succès | T7 (QA login) + T13 (QA finale step 5-7) |

Aucune section sans task associée.

**2. Placeholders**

Aucun `TBD`, `TODO`, `implement later`, ou snippet sans code. La copy maillage est complète FR + EN. Les chemins sont exacts.

**3. Cohérence types / noms**

- `data-screen` cohérent entre `_macros-maillage.ftl` (set) et `maillage.js` (read).
- Classes `kc-voice`, `kc-line`, `kc-line-aside`, `kc-terminal-card` cohérentes entre CSS, macro, et JS.
- Clés i18n `maillage.<screen>.label/line1..4/line_google` cohérentes entre `_macros-maillage.ftl`, `messages_fr/en.properties`.
- Flag sessionStorage `agflow_confident.seen.<screen>` (et `.<errorKey>` pour erreurs) cohérent avec spec §6.5–6.6.
- Variables env `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` cohérentes entre `yoops-realm.json` (substitution `${env...}`) et `03-apply-realm.sh` (export).

Pas de divergence détectée.

---

## Execution Handoff

Plan complet et sauvé dans `docs/superpowers/plans/2026-05-19-keycloak-theme-agflow-confident.md`. Deux options pour exécuter :

**1. Subagent-Driven (recommandée)** — je dispatche un sous-agent dédié pour chaque task, je relis entre chaque, on itère vite. Idéal vu que les tasks 1, 3, 7, 13 demandent des actions hors code (rotation secret, scp, accès admin LXC) que tu valideras à la main.

**2. Inline Execution** — j'exécute les tasks dans cette session avec des checkpoints de revue. Plus contigu mais plus de contexte cumulé dans la conversation.

Quel mode tu veux ?
