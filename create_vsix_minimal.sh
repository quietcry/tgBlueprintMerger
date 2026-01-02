#!/bin/bash
# Minimales Script zum Erstellen der VSIX-Datei
# Enthält nur package.json und extension.js (kein Script!)

set -e

cd "$(dirname "$0")"

echo "=== Erstelle minimale VSIX-Datei (Wrapper Extension) ==="
echo ""

# Wechsle ins Extension-Verzeichnis
cd tgBlueprintMergerExtension

# Prüfe ob package.json existiert
if [ ! -f "package.json" ]; then
    echo "✗ FEHLER: package.json nicht gefunden!"
    exit 1
fi

# Lese Version aus package.json
VERSION=$(grep -o '"version": "[^"]*"' package.json | cut -d'"' -f4)
VSIX_NAME="tg-merge-blueprint-${VERSION}.vsix"

# Zurück zum Root
cd ..

# Lösche alte VSIX-Dateien falls vorhanden
if [ -f "tg-merge-blueprint-*.vsix" ]; then
    rm -f tg-merge-blueprint-*.vsix
    echo "✓ Alte VSIX-Datei(en) gelöscht"
fi

# Wechsle wieder ins Extension-Verzeichnis
cd tgBlueprintMergerExtension

# Prüfe ob extension.js existiert
if [ ! -f "extension.js" ]; then
    echo "✗ FEHLER: extension.js nicht gefunden!"
    exit 1
fi

echo "✓ package.json gefunden"
echo "✓ extension.js gefunden"
echo ""
echo "Erstelle VSIX-Datei (nur minimale Dateien)..."
echo "HINWEIS: Das Script tgBlueprintMerger_yaml_jinja.sh muss im Workspace liegen!"

# Erstelle temporäres Verzeichnis mit extension/ Unterordner
# (Cursor erwartet möglicherweise diese Struktur)
TEMP_DIR=$(mktemp -d)
mkdir -p "$TEMP_DIR/extension"

# Kopiere Dateien in extension/ Unterordner
cp package.json "$TEMP_DIR/extension/"
cp extension.js "$TEMP_DIR/extension/"
if [ -f README.md ]; then
    cp README.md "$TEMP_DIR/extension/"
fi

# Speichere aktuelles Verzeichnis (ist bereits tgBlueprintMergerExtension)
ORIG_DIR=$(pwd)

# Erstelle ZIP-Datei aus dem temporären Verzeichnis
cd "$TEMP_DIR"
zip -r "$ORIG_DIR/../${VSIX_NAME}" extension/
cd "$ORIG_DIR"

# Aufräumen
rm -rf "$TEMP_DIR"

# Zurück zum ursprünglichen Verzeichnis (Repository-Root)
cd ..

# Prüfe ob VSIX-Datei erstellt wurde
if [ -f "${VSIX_NAME}" ]; then
    echo ""
    echo "✓ VSIX-Datei erfolgreich erstellt: ${VSIX_NAME}"
    
    # Zeige ZIP-Inhalt
    echo ""
    echo "VSIX-Inhalt:"
    unzip -l "${VSIX_NAME}"
    
    echo ""
    echo "Installation in VS Code/Cursor:"
    echo "  1. Öffnen Sie VS Code/Cursor"
    echo "  2. Drücken Sie Ctrl+Shift+P (oder Cmd+Shift+P auf macOS)"
    echo "  3. Wählen Sie 'Extensions: Install from VSIX...'"
    echo "  4. Wählen Sie die Datei: ${VSIX_NAME}"
    echo ""
    echo "WICHTIG: Das Script tgBlueprintMerger_yaml_jinja.sh muss im Workspace-Root liegen!"
    echo ""
else
    echo ""
    echo "✗ Fehler: VSIX-Datei wurde nicht erstellt"
    exit 1
fi

