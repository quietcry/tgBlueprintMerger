#!/bin/bash
# ============================================================================
# Wrapper-Script für zentrale Versionsverwaltung und Build
# ============================================================================
# 
# Dieses Script ist ein projektspezifischer Wrapper für das zentrale
# Versionsverwaltungs- und Build-Script. Es führt folgende Schritte aus:
#   1. Erhöht die Version in package.json automatisch
#   2. Baut die VSIX-Datei für die VS Code Extension
#   3. Erstellt einen Git-Tag mit der neuen Version
#
# Verwendung:
#   ./version_and_build.sh
#
# Das Script:
#   - Erhöht die Version automatisch (Format: JAHR.MONAT.INDEX)
#   - Baut die VSIX-Datei mit ./create_vsix_minimal.sh
#   - Erstellt einen Git-Tag (z.B. v2026.01.001)
#   - Gibt Anweisungen für den nächsten Commit aus
#
# Automatische Ausführung:
#   Der Git Pre-Commit Hook (.git/hooks/pre-commit) führt dieses Script
#   automatisch aus, wenn package.json geändert wurde.
#
# Zentrale Scripts (optional):
#   Das Script sucht automatisch nach zentralen Scripts in:
#   1. Umgebungsvariable GITHOOK_SCRIPTS_DIR
#   2. Übergeordneten Verzeichnissen (../githook_scripts/, ../../githook_scripts/, etc.)
#   3. Fallback: Lokale Implementierung wird verwendet
#
# Für andere Projekte:
#   Setzen Sie die Umgebungsvariable:
#   export GITHOOK_SCRIPTS_DIR="/pfad/zu/githook_scripts"
#   Oder platzieren Sie die Scripts in einem übergeordneten Verzeichnis
#
# ============================================================================

set -e

cd "$(dirname "$0")"

# Projektspezifische Konfiguration
PACKAGE_JSON="tgBlueprintMergerExtension/package.json"
BUILD_SCRIPT="./create_vsix_minimal.sh"

if [ ! -f "$PACKAGE_JSON" ]; then
    echo "✗ FEHLER: package.json nicht gefunden: $PACKAGE_JSON"
    exit 1
fi

# Suche zentrales Script (ohne absolute Pfade preiszugeben)
CENTRAL_SCRIPT=""

# Methode 1: Umgebungsvariable
if [ -n "$GITHOOK_SCRIPTS_DIR" ] && [ -f "$GITHOOK_SCRIPTS_DIR/version_and_build.sh" ]; then
    CENTRAL_SCRIPT="$GITHOOK_SCRIPTS_DIR/version_and_build.sh"
fi

# Methode 2: Suche in typischen Verzeichnissen relativ zum Projekt
if [ -z "$CENTRAL_SCRIPT" ]; then
    # Suche in übergeordneten Verzeichnissen nach githook_scripts
    for i in 1 2 3 4 5; do
        TEST_PATH=""
        case $i in
            1) TEST_PATH="../githook_scripts/version_and_build.sh" ;;
            2) TEST_PATH="../../githook_scripts/version_and_build.sh" ;;
            3) TEST_PATH="../../../githook_scripts/version_and_build.sh" ;;
            4) TEST_PATH="../../../../githook_scripts/version_and_build.sh" ;;
            5) TEST_PATH="../../../../../githook_scripts/version_and_build.sh" ;;
        esac
        if [ -f "$TEST_PATH" ]; then
            CENTRAL_SCRIPT="$TEST_PATH"
            break
        fi
    done
fi

# Methode 3: Lokale Implementierung (Fallback)
if [ -z "$CENTRAL_SCRIPT" ] || [ ! -f "$CENTRAL_SCRIPT" ]; then
    # Verwende lokale Implementierung
    echo "=== Automatische Versionierung und Build ==="
    echo ""
    
    # 1. Version erhöhen (verwende bump_version.sh)
    echo "1. Erhöhe Version..."
    NEW_VERSION=$(./bump_version.sh)
    if [ $? -ne 0 ]; then
        echo "✗ Fehler beim Erhöhen der Version"
        exit 1
    fi
    
    echo ""
    
    # 2. VSIX-Datei bauen
    echo "2. Baue VSIX-Datei..."
    ./create_vsix_minimal.sh
    if [ $? -ne 0 ]; then
        echo "✗ Fehler beim Erstellen der VSIX-Datei"
        exit 1
    fi
    
    NEW_VSIX="tg-merge-blueprint-${NEW_VERSION}.vsix"
    
    echo ""
    
    # 3. Git Tag erstellen
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$REPO_ROOT" ]; then
        TAG_NAME="v${NEW_VERSION}"
        if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
            echo "⚠ Tag $TAG_NAME existiert bereits, überspringe Tag-Erstellung"
        else
            echo "3. Erstelle Git Tag: $TAG_NAME"
            git tag -a "$TAG_NAME" -m "Version ${NEW_VERSION}"
            echo "✓ Git Tag erstellt: $TAG_NAME"
        fi
    fi
    
    echo ""
    echo "=== Fertig ==="
    echo "Version: $NEW_VERSION"
    echo "VSIX: $NEW_VSIX"
    if [ -n "$REPO_ROOT" ]; then
        echo "Tag: v${NEW_VERSION}"
        echo ""
        echo "Nächste Schritte:"
        echo "  1. git add tgBlueprintMergerExtension/package.json"
        echo "  2. git commit -m \"Bump version to ${NEW_VERSION}\""
        echo "  3. git push && git push --tags"
    fi
else
    # Führe zentrales Script aus (mit Build-Befehl)
    "$CENTRAL_SCRIPT" -b "$BUILD_SCRIPT" "$PACKAGE_JSON"
fi

