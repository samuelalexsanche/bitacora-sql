#!/usr/bin/env bash
# Arma index.html a partir de fuente/bitacora-sql.html y lo publica en GitHub Pages.
# Uso:
#   bash ~/Downloads/claude/bitacora-sql/publicar.sh               arma, hace commit y sube
#   bash ~/Downloads/claude/bitacora-sql/publicar.sh --solo-armar  solo arma index.html
#   MENSAJE="Texto del commit" bash …/publicar.sh                   con mensaje propio
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="bitacora-sql"
cd "$DIR"
[ -f fuente/bitacora-sql.html ] || { echo "No encuentro fuente/bitacora-sql.html"; exit 1; }

# index.html como documento completo (doctype, charset y viewport) con la página adentro
{
  printf '<!doctype html>\n<html lang="es">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n<meta name="description" content="Curso paso a paso de SQL: LDD, LMD, consultas, álgebra relacional y procedimientos almacenados, con ejercicios que se corrigen solos.">\n</head>\n<body>\n'
  cat fuente/bitacora-sql.html
  printf '\n</body>\n</html>\n'
} > index.html

if [ "${1:-}" = "--solo-armar" ]; then echo "index.html armado."; exit 0; fi

OWNER="$(gh api user -q .login)"
if [ ! -d .git ]; then git init -q -b main; fi
git add index.html fuente/bitacora-sql.html README.md publicar.sh
if ! git diff --cached --quiet; then
  git commit -q -m "${MENSAJE:-Actualiza la Bitácora SQL}" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
fi

if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -u origin main
else
  gh repo create "$OWNER/$REPO" --public --source . --remote origin --push \
    --description "Curso paso a paso de SQL con ejercicios que se corrigen solos"
fi

gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 || true

echo ""
echo "Listo. En uno o dos minutos queda en: https://$OWNER.github.io/$REPO/"
