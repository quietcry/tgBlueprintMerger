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
#   Das Script liest die Konfiguration aus project.json:
#   1. Erstellen Sie project.json basierend auf project.json.example
#   2. Setzen Sie githook_scripts_dir in der versioning Sektion
#   3. Fallback: Umgebungsvariable GITHOOK_SCRIPTS_DIR
#   4. Fallback: Lokale Implementierung wird verwendet
#
# Für andere Projekte:
#   Kopieren Sie project.json.example nach project.json und passen Sie an:
#   cp project.json.example project.json
#   # Bearbeiten Sie project.json und setzen Sie githook_scripts_dir
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

# Suche zentrales Script über project.json Konfiguration
CENTRAL_SCRIPT=""
PROJECT_JSON="project.json"

# Lese Konfiguration aus project.json (falls vorhanden)
if [ -f "$PROJECT_JSON" ]; then
    # Extrahiere githook_scripts_dir aus project.json
    if command -v jq >/dev/null 2>&1; then
        # Verwende jq falls verfügbar (präziser)
        GITHOOK_SCRIPTS_DIR=$(jq -r '.versioning.githook_scripts_dir // empty' "$PROJECT_JSON" 2>/dev/null)
    else
        # Fallback: Einfaches Parsing mit grep/sed
        GITHOOK_SCRIPTS_DIR=$(grep -o '"githook_scripts_dir"[[:space:]]*:[[:space:]]*"[^"]*"' "$PROJECT_JSON" | sed 's/.*"githook_scripts_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi
    
    if [ -n "$GITHOOK_SCRIPTS_DIR" ] && [ "$GITHOOK_SCRIPTS_DIR" != "null" ] && [ -f "$GITHOOK_SCRIPTS_DIR/bump_version.sh" ]; then
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
    CURRENT_VERSION_SEMANTIC=$(grep -o '"version": "[^"]*"' "$PACKAGE_JSON" | cut -d'"' -f4)
    echo "Aktuelle Version (semantisch): $CURRENT_VERSION_SEMANTIC"
    
    # Konvertiere semantische Version (2026.1.6) zu internem Format (2026.01.006)
    if [[ "$CURRENT_VERSION_SEMANTIC" =~ ^([0-9]{4})\.([0-9]+)\.([0-9]+)$ ]]; then
        OLD_YEAR="${BASH_REMATCH[1]}"
        OLD_MONTH="${BASH_REMATCH[2]}"
        OLD_INDEX="${BASH_REMATCH[3]}"
        # Normalisiere auf internes Format (mit führenden Nullen)
        OLD_MONTH_PADDED=$(printf "%02d" $((10#$OLD_MONTH)))
        OLD_INDEX_PADDED=$(printf "%03d" $((10#$OLD_INDEX)))
        CURRENT_VERSION_INTERNAL="${OLD_YEAR}.${OLD_MONTH_PADDED}.${OLD_INDEX_PADDED}"
    else
        echo "⚠ Warnung: Version entspricht nicht dem Format JAHR.MINOR.PATCH"
        CURRENT_VERSION_INTERNAL=""
    fi
    
    CURRENT_YEAR=$(date +%Y)
    CURRENT_MONTH=$(date +%m)
    DATE_PREFIX="${CURRENT_YEAR}.${CURRENT_MONTH}"
    
    if [ -z "$CURRENT_VERSION_INTERNAL" ] || [[ ! "$CURRENT_VERSION_INTERNAL" =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{3}$ ]]; then
        echo "⚠ Warnung: Aktuelle Version entspricht nicht dem Format JAHR.MONAT.INDEX"
        echo "Setze auf: ${DATE_PREFIX}.001"
        NEW_VERSION_INTERNAL="${DATE_PREFIX}.001"
    else
        OLD_YEAR=$(echo "$CURRENT_VERSION_INTERNAL" | cut -d'.' -f1)
        OLD_MONTH=$(echo "$CURRENT_VERSION_INTERNAL" | cut -d'.' -f2)
        OLD_INDEX=$(echo "$CURRENT_VERSION_INTERNAL" | cut -d'.' -f3)
        
        if [ "$OLD_YEAR" = "$CURRENT_YEAR" ] && [ "$OLD_MONTH" = "$CURRENT_MONTH" ]; then
            NEW_INDEX=$(printf "%03d" $((10#$OLD_INDEX + 1)))
            NEW_VERSION_INTERNAL="${DATE_PREFIX}.${NEW_INDEX}"
            echo "Gleicher Monat: Index erhöht von $OLD_INDEX auf $NEW_INDEX"
        else
            NEW_VERSION_INTERNAL="${DATE_PREFIX}.001"
            echo "Neuer Monat: Index auf 001 gesetzt"
        fi
    fi
    
    # Prüfe auf existierende Git-Tags (verwende internes Format)
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$REPO_ROOT" ]; then
        if git rev-parse "v${NEW_VERSION_INTERNAL}" >/dev/null 2>&1; then
            echo "⚠ Warnung: Tag v${NEW_VERSION_INTERNAL} existiert bereits"
            INDEX=$(echo "$NEW_VERSION_INTERNAL" | cut -d'.' -f3)
            INDEX=$((10#$INDEX))
            while git rev-parse "v${DATE_PREFIX}.$(printf "%03d" $INDEX)" >/dev/null 2>&1; do
                INDEX=$((INDEX + 1))
            done
            NEW_VERSION_INTERNAL="${DATE_PREFIX}.$(printf "%03d" $INDEX)"
            echo "Neue freie Version: $NEW_VERSION_INTERNAL"
        fi
    fi
    
    # Konvertiere internes Format (2026.01.006) zu semantischem Format (2026.1.6)
    NEW_YEAR=$(echo "$NEW_VERSION_INTERNAL" | cut -d'.' -f1)
    NEW_MONTH=$(echo "$NEW_VERSION_INTERNAL" | cut -d'.' -f2)
    NEW_INDEX=$(echo "$NEW_VERSION_INTERNAL" | cut -d'.' -f3)
    # Entferne führende Nullen für semantische Version
    NEW_MONTH_SEMANTIC=$((10#$NEW_MONTH))
    NEW_INDEX_SEMANTIC=$((10#$NEW_INDEX))
    NEW_VERSION_SEMANTIC="${NEW_YEAR}.${NEW_MONTH_SEMANTIC}.${NEW_INDEX_SEMANTIC}"
    
    # Aktualisiere Version in package.json (semantisches Format)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION_SEMANTIC\"/" "$PACKAGE_JSON"
    else
        sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION_SEMANTIC\"/" "$PACKAGE_JSON"
    fi
    
    echo "✓ Version aktualisiert: $CURRENT_VERSION_SEMANTIC → $NEW_VERSION_SEMANTIC"
    echo "$NEW_VERSION_SEMANTIC"
else
    # Führe zentrales Script aus
    "$CENTRAL_SCRIPT" "$PACKAGE_JSON"
fi

