#!/bin/bash
# ============================================================================
# Wrapper-Script für zentrale Versionsverwaltung
# ============================================================================
# 
# Dieses Script ist ein projektspezifischer Wrapper für das zentrale
# Versionsverwaltungs-Script. Es erhöht die Version in der package.json
# automatisch im Format JAHR.MONAT.INDEX (z.B. 2026.01.001).
#
# Verwendung:
#   ./bump_version.sh
#
# Das Script:
#   1. Liest die aktuelle Version aus tgBlueprintMergerExtension/package.json
#   2. Erhöht die Version automatisch (gleicher Monat: Index +1, neuer Monat: 001)
#   3. Aktualisiert die package.json mit der neuen Version
#   4. Gibt die neue Version aus
#
# Zentrale Scripts (optional):
#   Das Script liest die Konfiguration aus project.ini:
#   1. Erstellen Sie project.ini basierend auf project.ini.example
#   2. Setzen Sie githook_scripts_dir in der [versioning] Sektion
#   3. Fallback: Umgebungsvariable GITHOOK_SCRIPTS_DIR
#   4. Fallback: Lokale Implementierung wird verwendet
#
# Für andere Projekte:
#   Kopieren Sie project.ini.example nach project.ini und passen Sie an:
#   cp project.ini.example project.ini
#   # Bearbeiten Sie project.ini und setzen Sie githook_scripts_dir
#
# ============================================================================

set -e

cd "$(dirname "$0")"

# Projektspezifische Konfiguration
PACKAGE_JSON="tgBlueprintMergerExtension/package.json"

if [ ! -f "$PACKAGE_JSON" ]; then
    echo "✗ FEHLER: package.json nicht gefunden: $PACKAGE_JSON"
    exit 1
fi

# Suche zentrales Script über project.ini Konfiguration
CENTRAL_SCRIPT=""
PROJECT_INI="project.ini"

# Lese Konfiguration aus project.ini (falls vorhanden)
if [ -f "$PROJECT_INI" ]; then
    # Extrahiere githook_scripts_dir aus project.ini (ignoriere Kommentare und leere Zeilen)
    GITHOOK_SCRIPTS_DIR=$(grep -E "^[[:space:]]*githook_scripts_dir[[:space:]]*=" "$PROJECT_INI" | grep -v "^[[:space:]]*#" | cut -d'=' -f2 | tr -d '[:space:]' | sed "s/^['\"]//;s/['\"]$//")
    
    if [ -n "$GITHOOK_SCRIPTS_DIR" ] && [ -f "$GITHOOK_SCRIPTS_DIR/bump_version.sh" ]; then
        CENTRAL_SCRIPT="$GITHOOK_SCRIPTS_DIR/bump_version.sh"
    fi
fi

# Fallback: Umgebungsvariable
if [ -z "$CENTRAL_SCRIPT" ] && [ -n "$GITHOOK_SCRIPTS_DIR" ] && [ -f "$GITHOOK_SCRIPTS_DIR/bump_version.sh" ]; then
    CENTRAL_SCRIPT="$GITHOOK_SCRIPTS_DIR/bump_version.sh"
fi

# Methode 3: Lokale Implementierung (Fallback)
if [ -z "$CENTRAL_SCRIPT" ] || [ ! -f "$CENTRAL_SCRIPT" ]; then
    # Verwende lokale Implementierung direkt
    # (kopiere die Logik aus dem zentralen Script)
    CURRENT_VERSION=$(grep -o '"version": "[^"]*"' "$PACKAGE_JSON" | cut -d'"' -f4)
    echo "Aktuelle Version: $CURRENT_VERSION"
    
    CURRENT_YEAR=$(date +%Y)
    CURRENT_MONTH=$(date +%m)
    DATE_PREFIX="${CURRENT_YEAR}.${CURRENT_MONTH}"
    
    if [[ ! "$CURRENT_VERSION" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{3}$ ]]; then
        echo "⚠ Warnung: Aktuelle Version entspricht nicht dem Format JAHR.MONAT.INDEX"
        echo "Setze auf: ${DATE_PREFIX}.001"
        NEW_VERSION="${DATE_PREFIX}.001"
    else
        OLD_YEAR=$(echo "$CURRENT_VERSION" | cut -d'.' -f1)
        OLD_MONTH=$(echo "$CURRENT_VERSION" | cut -d'.' -f2)
        OLD_INDEX=$(echo "$CURRENT_VERSION" | cut -d'.' -f3)
        
        if [ "$OLD_YEAR" = "$CURRENT_YEAR" ] && [ "$OLD_MONTH" = "$CURRENT_MONTH" ]; then
            NEW_INDEX=$(printf "%03d" $((10#$OLD_INDEX + 1)))
            NEW_VERSION="${DATE_PREFIX}.${NEW_INDEX}"
            echo "Gleicher Monat: Index erhöht von $OLD_INDEX auf $NEW_INDEX"
        else
            NEW_VERSION="${DATE_PREFIX}.001"
            echo "Neuer Monat: Index auf 001 gesetzt"
        fi
    fi
    
    # Prüfe auf existierende Git-Tags
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$REPO_ROOT" ]; then
        if git rev-parse "v${NEW_VERSION}" >/dev/null 2>&1; then
            echo "⚠ Warnung: Tag v${NEW_VERSION} existiert bereits"
            INDEX=$(echo "$NEW_VERSION" | cut -d'.' -f3)
            INDEX=$((10#$INDEX))
            while git rev-parse "v${DATE_PREFIX}.$(printf "%03d" $INDEX)" >/dev/null 2>&1; do
                INDEX=$((INDEX + 1))
            done
            NEW_VERSION="${DATE_PREFIX}.$(printf "%03d" $INDEX)"
            echo "Neue freie Version: $NEW_VERSION"
        fi
    fi
    
    # Aktualisiere Version in package.json
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$PACKAGE_JSON"
    else
        sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" "$PACKAGE_JSON"
    fi
    
    echo "✓ Version aktualisiert: $CURRENT_VERSION → $NEW_VERSION"
    echo "$NEW_VERSION"
else
    # Führe zentrales Script aus
    "$CENTRAL_SCRIPT" "$PACKAGE_JSON"
fi

