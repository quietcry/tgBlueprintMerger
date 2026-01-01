#!/bin/bash
# Script zum Erstellen der VS Code Extension VSIX-Datei

set -e

cd "$(dirname "$0")"

echo "=== Building tgBlueprintMerger VS Code Extension ==="
echo ""

# Prüfe ob vsce installiert ist (global oder lokal)
VSCE_CMD=""
if command -v vsce &> /dev/null; then
    VSCE_CMD="vsce"
elif [ -f "./node_modules/.bin/vsce" ]; then
    VSCE_CMD="./node_modules/.bin/vsce"
elif [ -f "../node_modules/.bin/vsce" ]; then
    VSCE_CMD="../node_modules/.bin/vsce"
fi

if [ -z "$VSCE_CMD" ]; then
    echo "vsce (VS Code Extension Manager) ist nicht installiert"
    echo ""
    echo "Installation (OHNE Admin-Rechte):"
    echo "  cd tgBlueprintMergerExtension"
    echo "  npm install @vscode/vsce"
    echo "  (oder: npm install -g @vscode/vsce --prefix ~/.local)"
    echo ""
    echo "Alternative: VSIX manuell erstellen (siehe README)"
    echo ""
    exit 1
fi

# Prüfe ob Node.js installiert ist
if ! command -v node &> /dev/null; then
    echo "Error: Node.js ist nicht installiert"
    echo ""
    echo "Installation:"
    echo "  https://nodejs.org/"
    echo ""
    exit 1
fi

# Kopiere das aktuelle Script in die Extension
echo "Kopiere aktualisiertes Script in Extension..."
cp -f tgBlueprintMerger_yaml_jinja.sh tgBlueprintMergerExtension/tgBlueprintMerger_yaml_jinja.sh
echo "✓ Script aktualisiert"

# Wechsle ins Extension-Verzeichnis
cd tgBlueprintMergerExtension

# Erstelle VSIX-Datei
echo ""
echo "Erstelle VSIX-Datei mit: $VSCE_CMD"
$VSCE_CMD package --out ../tg-merge-blueprint-1.0.0.vsix

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ VSIX-Datei erfolgreich erstellt: tg-merge-blueprint-1.0.0.vsix"
    echo ""
    echo "Installation in VS Code/Cursor:"
    echo "  1. Öffnen Sie VS Code/Cursor"
    echo "  2. Drücken Sie Ctrl+Shift+P (oder Cmd+Shift+P auf macOS)"
    echo "  3. Wählen Sie 'Extensions: Install from VSIX...'"
    echo "  4. Wählen Sie die Datei: tg-merge-blueprint-1.0.0.vsix"
    echo ""
else
    echo ""
    echo "✗ Fehler beim Erstellen der VSIX-Datei"
    exit 1
fi

