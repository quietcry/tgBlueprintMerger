# tgMerge Blueprint Extension

Minimale VS Code/Cursor Extension (Wrapper) zum Ausführen des tgBlueprintMerger-Scripts für Blueprint-Dateien.

## Features

- **Save & Merge Button**: Button in der Editor-Toolbar für `*_*.yaml` Dateien
- **Status Bar Button**: Schnellzugriff über die Statusleiste
- **Command Palette**: Verfügbar über `Ctrl+Shift+P` → "Save & Merge Home Assistant Blueprint"
- **Automatisches Speichern**: Speichert die Datei vor dem Merge
- **Minimale Größe**: Enthält nur den nötigen Code für Buttons und Script-Aufruf

## Installation

### Als VSIX-Datei installieren:

1. VSIX-Datei erstellen:
   ```bash
   cd /pfad/zu/tgBlueprintMerger
   chmod +x create_vsix_minimal.sh
   ./create_vsix_minimal.sh
   ```

2. Extension installieren:
   - Öffnen Sie VS Code/Cursor
   - `Ctrl+Shift+P` (oder `Cmd+Shift+P` auf macOS)
   - Wählen Sie "Extensions: Install from VSIX..."
   - Wählen Sie die Datei: `tg-merge-blueprint-1.0.0.vsix`

### Entwicklung/Testen:

1. Extension-Ordner in VS Code/Cursor öffnen:
   ```bash
   code /pfad/zu/tgBlueprintMerger/tgBlueprintMergerExtension
   ```

2. `F5` drücken zum Debuggen/Testen

## Verwendung

1. **WICHTIG**: Das Script `tgBlueprintMerger_yaml_jinja.sh` muss im Workspace-Root liegen!
2. Öffne eine `*_*.yaml` Datei (z.B. `myBlueprint_.yaml`)
3. Klicke auf den "Save & Merge Home Assistant Blueprint" Button in der Toolbar
4. Oder verwende `Ctrl+Shift+P` → "Save & Merge Home Assistant Blueprint"
5. Die Datei wird gespeichert und das Merge-Script wird ausgeführt

## Konfiguration

Falls das Script nicht im Workspace-Root liegt, können Sie den Pfad in den Einstellungen konfigurieren:

- `Ctrl+Shift+P` → "Preferences: Open Settings (UI)"
- Suche nach "tgBlueprintMerger"
- Setze `tgBlueprintMerger.scriptPath` auf den Pfad zum Script (absolut oder relativ zum Workspace-Root)

## Anforderungen

- Das Script `tgBlueprintMerger_yaml_jinja.sh` muss im Workspace-Root liegen (oder konfiguriert werden)
- Bash muss verfügbar sein











