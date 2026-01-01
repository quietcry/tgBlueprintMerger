#!/bin/bash
# Minimales Script zum Erstellen der VSIX-Datei
# Enthält nur package.json und extension.js (kein Script!)

set -e

cd "$(dirname "$0")"

echo "=== Erstelle minimale VSIX-Datei (Wrapper Extension) ==="
echo ""

# Lösche alte VSIX-Datei falls vorhanden
if [ -f "tg-merge-blueprint-1.0.0.vsix" ]; then
    rm -f tg-merge-blueprint-1.0.0.vsix
    echo "✓ Alte VSIX-Datei gelöscht"
fi

# Wechsle ins Extension-Verzeichnis
cd tgBlueprintMergerExtension

# Prüfe ob package.json existiert
if [ ! -f "package.json" ]; then
    echo "✗ FEHLER: package.json nicht gefunden!"
    exit 1
fi

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
zip -r "$ORIG_DIR/../tg-merge-blueprint-1.0.0.vsix" extension/
cd "$ORIG_DIR"

# Aufräumen
rm -rf "$TEMP_DIR"

# Zurück zum ursprünglichen Verzeichnis (Repository-Root)
cd ..

# Prüfe ob VSIX-Datei erstellt wurde
if [ -f "tg-merge-blueprint-1.0.0.vsix" ]; then
    echo ""
    echo "✓ VSIX-Datei erfolgreich erstellt: tg-merge-blueprint-1.0.0.vsix"
    
    # Zeige ZIP-Inhalt
    echo ""
    echo "VSIX-Inhalt:"
    unzip -l tg-merge-blueprint-1.0.0.vsix
    
    echo ""
    echo "Installation in VS Code/Cursor:"
    echo "  1. Öffnen Sie VS Code/Cursor"
    echo "  2. Drücken Sie Ctrl+Shift+P (oder Cmd+Shift+P auf macOS)"
    echo "  3. Wählen Sie 'Extensions: Install from VSIX...'"
    echo "  4. Wählen Sie die Datei: tg-merge-blueprint-1.0.0.vsix"
    echo ""
    echo "WICHTIG: Das Script tgBlueprintMerger_yaml_jinja.sh muss im Workspace-Root liegen!"
    echo ""
else
    echo ""
    echo "✗ Fehler: VSIX-Datei wurde nicht erstellt"
    exit 1
fi

