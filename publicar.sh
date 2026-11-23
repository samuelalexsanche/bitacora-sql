#!/usr/bin/env bash
# Publica la Bitácora SQL en GitHub Pages, en el repo público <tu-usuario>/bitacora-sql.
# Crea (o actualiza) la carpeta ~/Downloads/claude/bitacora-sql con el repo.
# Se puede volver a correr para subir una versión nueva.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
DIR="$HOME/Downloads/claude/bitacora-sql"
REPO="bitacora-sql"

mkdir -p "$DIR/fuente"
cp "$SRC_DIR/bitacora-sql.html" "$DIR/fuente/bitacora-sql.html"
cp "$SRC_DIR/README.md" "$DIR/README.md"
cp "$SRC_DIR/publicar.sh" "$DIR/publicar.sh"
cd "$DIR"

# index.html como documento completo (doctype, charset y viewport) con la página adentro
{
  printf '<!doctype html>\n<html lang="es">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n<meta name="description" content="Curso paso a paso de SQL: LDD, LMD, consultas, álgebra relacional y procedimientos almacenados, con ejercicios que se corrigen solos.">\n</head>\n<body>\n'
  cat fuente/bitacora-sql.html
  printf '\n</body>\n</html>\n'
} > index.html

OWNER="$(gh api user -q .login)"
if [ ! -d .git ]; then git init -q -b main; fi
git add index.html fuente/bitacora-sql.html README.md publicar.sh
if ! git diff --cached --quiet; then
  git commit -q -m "Publica la Bitácora SQL" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
fi

if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -u origin main
else
  gh repo create "$OWNER/$REPO" --public --source . --remote origin --push \
    --description "Curso paso a paso de SQL con ejercicios que se corrigen solos"
fi

# Activa GitHub Pages desde la rama main (si ya estaba activo, no pasa nada)
gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

echo ""
echo "Listo. En uno o dos minutos queda en: https://$OWNER.github.io/$REPO/"
