#!/usr/bin/env bash
# Sella la versión (build + commit + fecha/hora) en el footer de la app.
# Se ejecuta desde el hook pre-commit: usa el commit que se está creando
# (build = commits actuales + 1, fecha = ahora) para reflejar la publicación.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BUILD=$(( $(git rev-list --count HEAD 2>/dev/null || echo 0) + 1 ))
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "inicial")
DATE=$(date '+%Y-%m-%d %H:%M')

export SPAN="<span id=\"appVer\" data-build=\"$BUILD\" data-commit=\"$COMMIT\" data-date=\"$DATE\">versión $BUILD · publicada $DATE</span>"

# Archivos que pueden contener el sello (activo + respaldos)
for f in app/index.html ethfi-monitor/index.html Monitor_ETHFI.html.txt; do
  [ -f "$f" ] || continue
  grep -q 'id="appVer"' "$f" || continue
  perl -0pi -e 's{<span id="appVer"[^>]*>.*?</span>}{$ENV{SPAN}}s' "$f"
  git add "$f"
done

echo "versión sellada: build $BUILD · $COMMIT · $DATE"
