# tgMerge Blueprint Extension

VS Code/Cursor Extension zum Ausführen des tgMerge-Scripts für Blueprint-Dateien.

## Features

- **Save & Merge Button**: Button in der Editor-Toolbar für `*_*.yaml` Dateien
- **Status Bar Button**: Schnellzugriff über die Statusleiste
- **Command Palette**: Verfügbar über `Ctrl+Shift+P` → "Save & Merge Blueprint"
- **Automatisches Speichern**: Speichert die Datei vor dem Merge

## Installation

1. Extension-Ordner in VS Code/Cursor öffnen:
   ```bash
   # Vom Repository-Root aus:
   code tgMergeExtension
   
   # Oder mit absolutem Pfad:
   code /pfad/zu/tgBlueprintMerger/tgMergeExtension
   ```

2. Extension installieren:
   - `F5` drücken zum Debuggen/Testen
   - Oder: `Ctrl+Shift+P` → "Extensions: Install from VSIX" (wenn als VSIX gepackt)

## Verwendung

1. Öffne eine `*_*.yaml` Datei (z.B. `myBlueprint_.yaml`)
2. Klicke auf den "Save & Merge Blueprint" Button in der Toolbar
3. Oder verwende `Ctrl+Shift+P` → "Save & Merge Blueprint"
4. Die Datei wird gespeichert und das Merge-Script wird ausgeführt

## Anforderungen

- Das Script `tgMergeOnSave_yaml_jinja.sh` muss im übergeordneten Verzeichnis liegen
- Bash muss verfügbar sein











