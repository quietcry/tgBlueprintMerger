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

# Lösche alle alten VSIX-Dateien (inklusive der aktuellen Version, falls vorhanden)
OLD_VSIX_COUNT=0
for old_vsix in tg-merge-blueprint-*.vsix; do
    # Prüfe ob Datei existiert (Wildcard könnte nicht matchen)
    if [ -f "$old_vsix" ]; then
        rm -f "$old_vsix"
        OLD_VSIX_COUNT=$((OLD_VSIX_COUNT + 1))
    fi
done

if [ $OLD_VSIX_COUNT -gt 0 ]; then
    echo "✓ $OLD_VSIX_COUNT alte VSIX-Datei(en) gelöscht"
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

# Speichere aktuelles Verzeichnis (ist bereits tgBlueprintMergerExtension)
ORIG_DIR=$(pwd)
VSIX_PATH="$ORIG_DIR/../${VSIX_NAME}"

# Erstelle VSIX mit Python für präzise ZIP-Struktur
# Dateien müssen in extension/ Unterordner liegen
python3 << PYTHON_SCRIPT
import zipfile
import os
import shutil
from pathlib import Path

# Temporäres Verzeichnis
temp_dir = Path("/tmp/vsix_create")
temp_ext_dir = temp_dir / "extension"

# Alte VSIX löschen
if os.path.exists("${VSIX_PATH}"):
    os.remove("${VSIX_PATH}")

# Temporäres Verzeichnis erstellen
if temp_dir.exists():
    shutil.rmtree(temp_dir)
temp_ext_dir.mkdir(parents=True)

# Dateien in extension/ Unterordner kopieren
shutil.copy("package.json", temp_ext_dir / "package.json")
shutil.copy("extension.js", temp_ext_dir / "extension.js")
if os.path.exists("README.md"):
    shutil.copy("README.md", temp_ext_dir / "README.md")

# ZIP erstellen - Dateien in extension/ Unterordner
with zipfile.ZipFile("${VSIX_PATH}", 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(temp_ext_dir):
        for file in files:
            file_path = Path(root) / file
            # Relativer Pfad: extension/package.json
            arcname = file_path.relative_to(temp_ext_dir.parent)
            zipf.write(file_path, arcname)

# Aufräumen
shutil.rmtree(temp_dir)
PYTHON_SCRIPT

if [ $? -ne 0 ]; then
    echo "✗ FEHLER: Python-Script fehlgeschlagen, verwende Fallback mit zip"
    # Fallback: Verwende zip - Dateien in extension/ Unterordner
    TEMP_DIR=$(mktemp -d)
    EXT_DIR="$TEMP_DIR/extension"
    mkdir -p "$EXT_DIR"
    cp package.json "$EXT_DIR/"
    cp extension.js "$EXT_DIR/"
    if [ -f README.md ]; then
        cp README.md "$EXT_DIR/"
    fi
    cd "$TEMP_DIR"
    # Dateien in extension/ Unterordner
    zip -r "$VSIX_PATH" extension/
    cd "$ORIG_DIR"
    rm -rf "$TEMP_DIR"
fi

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

