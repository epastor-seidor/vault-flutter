#!/bin/bash
set -e

echo "============================================"
echo "  DevVault - Actualizar Documentación"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "[1/5] Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter no está instalado"
    exit 1
fi
echo "OK"
echo ""

echo "[2/5] Instalando dependencias..."
flutter pub get
echo ""

echo "[3/5] Analizando código..."
flutter analyze --no-fatal-infos --no-fatal-warnings
echo ""

echo "[4/5] Verificando documentación existente..."
DOCS_OK=true
for doc in README.md docs/arquitectura.md docs/guia-desarrollo.md docs/guia-usuario.md; do
    if [ -f "$doc" ]; then
        echo "  ✅ $doc"
    else
        echo "  ❌ $doc (falta)"
        DOCS_OK=false
    fi
done
echo ""

echo "[5/5] Actualizando fechas en documentación..."
TODAY=$(date +"%d de %B, %Y")
for doc in docs/arquitectura.md docs/guia-desarrollo.md docs/guia-usuario.md; do
    if [ -f "$doc" ]; then
        sed -i "s/Última actualización:.*/Última actualización: $TODAY/" "$doc"
        echo "  📅 $doc"
    fi
done
echo ""

echo "============================================"
echo "  Documentación actualizada correctamente"
echo "============================================"
echo ""
echo "Para commitear los cambios:"
echo "  git add README.md docs/"
echo "  git commit -m \"docs: actualizar documentación\""
echo ""
