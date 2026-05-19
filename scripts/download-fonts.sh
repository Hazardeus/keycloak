#!/usr/bin/env bash
# Télécharge les polices self-hostées pour agflow-confident.
# Idempotent : skip si déjà présent.
#
# - JetBrains Mono Regular / Medium : récupérés depuis le release GitHub officiel.
# - Fraunces variable (normal + italic) : extraits depuis l'API CSS Google Fonts.
#   On utilise un User-Agent Chrome moderne pour forcer la livraison de woff2
#   variables (sans UA moderne, Google sert des .ttf statiques par poids).
#   On garde le subset "latin" (le dernier @font-face par style) — suffisant
#   pour une page de login Keycloak et le plus léger.

set -euo pipefail

DEST="$(cd "$(dirname "$0")/.." && pwd)/Theme/agflow-confident/login/resources/fonts"
mkdir -p "$DEST"

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

declare -A FONTS=(
  ["JetBrainsMono-Regular.woff2"]="https://github.com/JetBrains/JetBrainsMono/raw/v2.304/fonts/webfonts/JetBrainsMono-Regular.woff2"
  ["JetBrainsMono-Medium.woff2"]="https://github.com/JetBrains/JetBrainsMono/raw/v2.304/fonts/webfonts/JetBrainsMono-Medium.woff2"
)

for name in "${!FONTS[@]}"; do
  if [[ -f "$DEST/$name" ]]; then
    echo "skip $name (déjà présent)"
  else
    echo "fetch $name"
    curl -fL --retry 3 -o "$DEST/$name" "${FONTS[$name]}"
  fi
done

# Fraunces variable — récupération via l'API CSS Google Fonts.
# UA Chrome obligatoire pour obtenir des woff2 variables et non des .ttf statiques.
FRAUNCES_CSS="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300..400;1,9..144,300..400&display=swap"

fetch_fraunces() {
  local style="$1"   # normal | italic
  local out="$2"

  if [[ -f "$DEST/$out" ]]; then
    echo "skip $out (déjà présent)"
    return 0
  fi
  echo "fetch $out"

  # On récupère le CSS, on découpe par @font-face, on garde le bloc qui matche
  # `font-style: <style>;` et dont l'unicode-range commence par U+0000 (= subset latin).
  # On retourne la première URL https://....woff2 trouvée dans ce bloc.
  local url
  url=$(curl -fsSL --retry 3 -H "User-Agent: $UA" "$FRAUNCES_CSS" \
    | awk -v want="$style" 'BEGIN{RS="@font-face"}
        $0 ~ ("font-style: " want ";") && $0 ~ /unicode-range: U\+0000/ {
          if (match($0, /https:\/\/[^)]+\.woff2/)) {
            print substr($0, RSTART, RLENGTH); exit
          }
        }')

  if [[ -z "$url" ]]; then
    echo "ERREUR: impossible d'extraire l'URL woff2 latine pour $out depuis Google Fonts." >&2
    echo "Vérifie manuellement: curl -H \"User-Agent: $UA\" \"$FRAUNCES_CSS\"" >&2
    return 1
  fi

  curl -fL --retry 3 -H "User-Agent: $UA" -o "$DEST/$out" "$url"
}

fetch_fraunces "normal" "Fraunces-Variable.woff2"
fetch_fraunces "italic" "Fraunces-Italic-Variable.woff2"

echo ""
echo "OK — polices dans $DEST :"
ls -la "$DEST"
