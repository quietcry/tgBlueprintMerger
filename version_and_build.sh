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
# Zentrale Scripts:
#   - /tgdata/coding/githook_scripts/bump_version.sh
#   - /tgdata/coding/githook_scripts/version_and_build.sh
#
# Für andere Projekte:
#   Verwenden Sie das zentrale Script direkt:
#   /tgdata/coding/githook_scripts/version_and_build.sh -b "<BUILD_CMD>" <DATEI>
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

# Verwende zentrales Script
CENTRAL_SCRIPT="/tgdata/coding/githook_scripts/version_and_build.sh"

if [ ! -f "$CENTRAL_SCRIPT" ]; then
    echo "✗ FEHLER: Zentrales Script nicht gefunden: $CENTRAL_SCRIPT"
    echo "Bitte stellen Sie sicher, dass das zentrale Script existiert."
    exit 1
fi

# Führe zentrales Script aus (mit Build-Befehl)
"$CENTRAL_SCRIPT" -b "$BUILD_SCRIPT" "$PACKAGE_JSON"

