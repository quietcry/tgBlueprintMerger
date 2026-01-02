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
# Zentrale Scripts:
#   - /tgdata/coding/githook_scripts/bump_version.sh
#   - /tgdata/coding/githook_scripts/version_and_build.sh
#
# Für andere Projekte:
#   Verwenden Sie das zentrale Script direkt:
#   /tgdata/coding/githook_scripts/bump_version.sh <DATEI>
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

# Verwende zentrales Script
CENTRAL_SCRIPT="/tgdata/coding/githook_scripts/bump_version.sh"

if [ ! -f "$CENTRAL_SCRIPT" ]; then
    echo "✗ FEHLER: Zentrales Script nicht gefunden: $CENTRAL_SCRIPT"
    echo "Bitte stellen Sie sicher, dass das zentrale Script existiert."
    exit 1
fi

# Führe zentrales Script aus
"$CENTRAL_SCRIPT" "$PACKAGE_JSON"

