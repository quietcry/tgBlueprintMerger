# tgBlueprintMerger - Home Assistant Blueprint Merger

> **Sprache**: 🇩🇪 Deutsch | [🇬🇧 English](README_en.md)

Ein modulares Build-System für Home Assistant Blueprints, das es ermöglicht, komplexe Blueprint-Dateien in übersichtliche, wiederverwendbare Module aufzuteilen und automatisch zu einer finalen Blueprint-Datei zusammenzuführen.

## 📋 Inhaltsverzeichnis

- [Überblick](#überblick)
- [Features](#features)
- [Installation](#installation)
- [Schnellstart](#schnellstart)
- [Konzepte](#konzepte)
- [Marker-Syntax](#marker-syntax)
- [Verwendung](#verwendung)
- [Beispiele](#beispiele)
- [Internationalisierung (i18n)](#-internationalisierung-i18n)
- [Doc-Tag-Filterung](#-doc-tag-filterung)
- [Hooks](#-hooks)
- [Architektur](#️-architektur)
- [Troubleshooting](#-troubleshooting)
- [Entwicklung](#-entwicklung)

## 🎯 Überblick

**tgBlueprintMerger**  ist ein Build-Tool für Home Assistant Blueprints, das die modulare Entwicklung von komplexen Automatisierungen ermöglicht. Anstatt eine große, unübersichtliche YAML-Datei zu pflegen, können Sie Ihre Blueprints in logische Module aufteilen:

- **Input-Definitionen** → `*_input.yaml`
- **Trigger-Logik** → `*_trigger.yaml`
- **Bedingungen** → `*_condition.yaml`
- **Aktionen** → `*_action.yaml`
- **Jinja-Templates** → `*_var_*.jinja`
- **Debug-Code** → `*_debug_*.yaml`

Das System fügt diese Module automatisch zu einer finalen, Home Assistant-kompatiblen Blueprint-Datei zusammen.

## ✨ Features

### Core-Funktionalität
- ✅ **Modulares System**: Aufteilen von Blueprints in wiederverwendbare Komponenten
- ✅ **Automatisches Merging**: Zusammenführung mehrerer Dateien zu einer finalen Blueprint
- ✅ **Verschachtelte Merges**: Unterstützung für rekursive Merge-Operationen (bis zu 10 Ebenen)
- ✅ **🔑 Einrückungserhaltung**: **Kritische Funktion** - Der eingefügte Inhalt wird **exakt an der Einrückungsposition des Markers** eingefügt. Die Einrückung des Markers wird extrahiert und auf jede Zeile des eingefügten Inhalts angewendet, sodass die YAML-Struktur korrekt erhalten bleibt.
- ✅ **YAML & Jinja**: Unterstützung für beide Dateiformate
- ✅ **Conditional Merges**: Fallback-Mechanismus mit `TRUE-tgMerger` Markern
- ✅ **Externe Dateien**: Einbindung von Dateien aus anderen Verzeichnissen (z.B. gemeinsame Jinja-Makros, Code-Snippets)
- ✅ **🌍 Internationalisierung (i18n)**: Automatische Übersetzung von Blueprints in mehrere Sprachen
- ✅ **📝 Doc-Tag-Filterung**: Automatisches Entfernen von Dokumentationsblöcken (`#Doc-Start` / `#Doc-End`)

### VS Code/Cursor Integration
- 🎨 **Toolbar-Button**: Direkter Zugriff über Editor-Toolbar
- 📊 **Status Bar**: Schnellzugriff über Statusleiste
- ⌨️ **Command Palette**: Verfügbar über `Ctrl+Shift+P`
- 💾 **Auto-Save**: Automatisches Speichern vor dem Merge
- 📝 **Progress Feedback**: Visuelles Feedback während des Merging-Prozesses

### Erweiterte Features
- 🔧 **Pre/Post Hooks**: Ausführbare Skripte vor/nach dem Merge
- 🔄 **Rekursive Verarbeitung**: Automatische Verarbeitung verschachtelter Merges
- ⚠️ **Fehlerbehandlung**: Detaillierte Fehlermeldungen bei Problemen
- 📁 **Pfad-Unterstützung**: Relative und absolute Pfade für externe Dateien
- 🌍 **Internationalisierung (i18n)**: Automatische Übersetzung in mehrere Sprachen mit Marker-Syntax
- 📝 **Doc-Tag-Filterung**: Automatisches Entfernen von Dokumentationsblöcken (`#Doc-Start` / `#Doc-End`)
- 🧹 **Saubere Ausgabe**: Automatisches Entfernen führender Leerzeilen

## 🚀 Installation

### Voraussetzungen

- **Bash**: Muss im System verfügbar sein (standardmäßig auf Linux/macOS)
- **VS Code oder Cursor**: Für die Extension-Integration
- **Node.js**: Für die VS Code Extension (wird normalerweise mit VS Code installiert)

### Schritt 1: Repository klonen oder herunterladen

```bash
# Repository klonen
git clone https://github.com/IhrBenutzername/tgBlueprintMerger.git
cd tgBlueprintMerger

# Oder wenn Sie das Repository bereits haben:
cd /pfad/zu/ihrem/tgBlueprintMerger
```

### Schritt 2: VS Code Extension installieren

**Wichtig**: Die Extension ist eine minimale Wrapper-Extension. Das Script `tgBlueprintMerger_yaml_jinja.sh` muss im Workspace-Root liegen.

1. Erstellen Sie die VSIX-Datei:
   ```bash
   cd /pfad/zu/tgBlueprintMerger
   chmod +x create_vsix_minimal.sh
   ./create_vsix_minimal.sh
   ```

2. Installieren Sie die VSIX-Datei:
   - `Ctrl+Shift+P` → "Extensions: Install from VSIX..."
   - Wählen Sie die Datei `tg-merge-blueprint-1.0.0.vsix` aus dem Repository-Root

### Schritt 3: Script im Workspace platzieren

**Wichtig**: Das Script `tgBlueprintMerger_yaml_jinja.sh` muss im Workspace-Root liegen, damit die Extension es finden kann.

1. Kopieren Sie das Script in Ihr Workspace-Root:
   ```bash
   cp /pfad/zu/tgBlueprintMerger/tgBlueprintMerger_yaml_jinja.sh /pfad/zu/ihrem/workspace/
   ```

2. Machen Sie das Script ausführbar:
   ```bash
   chmod +x /pfad/zu/ihrem/workspace/tgBlueprintMerger_yaml_jinja.sh
   ```

### Schritt 4: Konfiguration (Optional)

Die Extension sucht das Script in folgender Reihenfolge:
1. **Konfigurierter Pfad** (falls in Einstellungen gesetzt)
2. **Workspace-Root** (empfohlen)
3. **Übergeordnete Verzeichnisse** (bis zu 10 Ebenen)

Falls Sie einen benutzerdefinierten Pfad verwenden möchten:

1. Öffnen Sie die Einstellungen: `Ctrl+,` (oder `Cmd+,` auf macOS)
2. Suchen Sie nach `tgBlueprintMerger.scriptPath`
3. Geben Sie den Pfad zum Script ein:
   - **Absoluter Pfad**: `/pfad/zum/tgBlueprintMerger_yaml_jinja.sh`
   - **Relativer Pfad**: `tgBlueprintMerger_yaml_jinja.sh` (relativ zum Workspace-Root)
   - **Leer lassen**: Automatische Suche wird verwendet (empfohlen)

### Schritt 5: Verifizierung

1. Öffnen Sie eine Home Assistant Blueprint-Datei mit dem Muster `*_*.yaml` (z.B. `myBlueprint_.yaml`)
2. Sie sollten den "Save & Merge Home Assistant Blueprint" Button in der Toolbar sehen
3. Testen Sie den Merge-Prozess

## 🏃 Schnellstart

### Beispiel: Einfacher Home Assistant Blueprint

1. **Erstellen Sie ein Verzeichnis** `myBlueprint/` und darin eine Basisdatei `myBlueprint_.yaml`:
   **Wichtig**: Der Dateiname muss dem Verzeichnisnamen entsprechen (mit `_` vor `.yaml`)
   ```yaml
   blueprint:
     name: My Blueprint
     domain: automation
   
   input:
     #START-tgMerger=myBlueprint_input.yaml
     #END-tgMerger
   
   trigger:
     #START-tgMerger=myBlueprint_trigger.yaml
     #END-tgMerger
   ```

2. **Erstellen Sie die Modul-Dateien**:

   `myBlueprint_input.yaml`:
   ```yaml
   test_input:
     name: Test Input
     default: "Hallo"
     selector:
       text:
   ```

   `myBlueprint_trigger.yaml`:
   ```yaml
   - platform: state
     entity_id: input_text.test
   ```

3. **Führen Sie den Merge aus**:
   - Öffnen Sie **irgendeine Datei** im Verzeichnis `myBlueprint/` (z.B. `myBlueprint_input.yaml`)
   - Speichern Sie die Datei
   - Klicken Sie auf "Save & Merge Home Assistant Blueprint" Button
   - Oder: `Ctrl+Shift+P` → "Save & Merge Home Assistant Blueprint"
   - **Hinweis**: Die Extension findet automatisch die Basisdatei `myBlueprint_.yaml` basierend auf dem Verzeichnisnamen

4. **Ergebnis**: Die Datei `myBlueprint.yaml` wird im Verzeichnis `myBlueprint/` erstellt mit allen Modulen zusammengeführt.

**Optional - Mit `.package` Datei:**
- Erstellen Sie eine Datei `customName.package` im Verzeichnis `myBlueprint/`
- Die finale Datei wird dann `customName.yaml` heißen (statt `myBlueprint.yaml`)
- Die Basisdatei bleibt weiterhin `myBlueprint_.yaml` (basierend auf Verzeichnisname)

## 📚 Konzepte

### Dateinamen-Konvention

Das System verwendet eine spezielle Namenskonvention, die auf dem **Verzeichnisnamen** basiert:

#### Basisdatei-Name wird aus Verzeichnisname abgeleitet

**Wichtig**: Der Name der Basisdatei wird **immer** aus dem Verzeichnisnamen abgeleitet, in dem sich die Blueprint-Dateien befinden.

- **Basisdatei**: `[verzeichnisname]_.yaml` (mit Unterstrich vor `.yaml`)
  - Der Verzeichnisname bestimmt den Basisdatei-Namen
  - Beispiel: Verzeichnis `example/` → Basisdatei: `example_.yaml`
  - Beispiel: Verzeichnis `myBlueprint/` → Basisdatei: `myBlueprint_.yaml`

#### Finale Datei (Output)

- **Ohne `.package` Datei**: Der Verzeichnisname wird auch für die finale Datei verwendet
  - Beispiel: Verzeichnis `example/` → Output: `example.yaml`
  
- **Mit `.package` Datei**: Der Name der `.package` Datei bestimmt den finalen Blueprint-Namen
  - Die `.package` Datei kann einen **beliebigen Namen** haben (unabhängig vom Verzeichnis- oder Basisdatei-Namen)
  - Beispiel: Verzeichnis `example/` mit `myBlueprintExample.package` → Output: `myBlueprintExample.yaml`
  - Dies ermöglicht es, den finalen Blueprint-Namen unabhängig vom Verzeichnisnamen zu wählen

#### Zusammenfassung

| Szenario | Verzeichnis | Basisdatei | `.package` Datei | Finale Datei |
|----------|-------------|------------|------------------|--------------|
| Standard | `example/` | `example_.yaml` | - | `example.yaml` |
| Mit Package | `example/` | `example_.yaml` | `myBlueprintExample.package` | `myBlueprintExample.yaml` |

#### Modul-Dateien

- **Modul-Dateien**: Beliebig benennbar, werden über Marker referenziert
  - Beispiel: `myBlueprintExample_input.yaml`, `myBlueprintExample_trigger.yaml`
  - Die Modul-Dateien können beliebige Namen haben, müssen nicht dem Verzeichnis- oder Package-Namen entsprechen

### Merge-Prozess

1. **Verzeichnisanalyse**: 
   - Das Script bestimmt den Verzeichnisnamen der übergebenen Datei
   - Die Basisdatei wird als `[verzeichnisname]_.yaml` gesucht
   - Falls eine `.package` Datei existiert, wird deren Name für die finale Datei verwendet
   
2. **Input**: Basisdatei `[verzeichnisname]_.yaml` wird gelesen
   - Die Basisdatei muss im gleichen Verzeichnis wie die übergebene Datei liegen
   
3. **Parsing**: Script sucht nach `tgMerger` Markern in der Basisdatei
   
4. **Einrückungsextraktion**: **Kritischer Schritt** - Die Einrückung (Leerzeichen/Tabs) vor dem Marker wird erfasst
   
5. **Resolving**: Referenzierte Dateien werden geladen (lokal oder extern über relativen Pfad)
   - Alle Pfade sind relativ zum Verzeichnis der Basisdatei
   
6. **Merging**: Dateiinhalte werden eingefügt:
   - **Jede Zeile** des eingefügten Inhalts erhält die extrahierte Einrückung
   - Die Einrückung wird **additiv** angewendet (Marker-Einrückung + eventuelle interne Einrückung der Datei)
   
7. **Recursion**: Verschachtelte Merges werden rekursiv verarbeitet (bis zu 10 Ebenen)
   
8. **Output**: Finale Datei wird erstellt:
   - **Ohne `.package` Datei**: `[verzeichnisname].yaml`
   - **Mit `.package` Datei**: `[package-name].yaml` (Name aus `.package` Datei)

### 🔑 Einrückungserhaltung - Das Herzstück des Systems

Die **Einrückungserhaltung** ist eine der wichtigsten Funktionen von tgMerge. Sie stellt sicher, dass die YAML-Struktur nach dem Merge korrekt bleibt.

**Wie es funktioniert:**

1. **Marker-Position bestimmt Einrückung:**
   ```yaml
   variables:
     config: >-
       {# START-tgMerger=config.jinja #}    # ← 8 Leerzeichen Einrückung
       {#END-tgMerger#}
   ```
   Das Script erkennt: "Der Marker hat 8 Leerzeichen Einrückung"

2. **Einrückung wird auf jede Zeile angewendet:**
   ```jinja
   # Inhalt von config.jinja (ohne Einrückung):
   {%- set value = "test" -%}
   {{- value -}}
   ```
   
   Wird zu (mit 8 Leerzeichen):
   ```yaml
   variables:
     config: >-
       {%- set value = "test" -%}    # ← 8 Leerzeichen hinzugefügt
       {{- value -}}                 # ← 8 Leerzeichen hinzugefügt
   ```

3. **Interne Einrückung wird beibehalten:**
   Wenn die eingefügte Datei bereits Einrückung hat, wird diese beibehalten:
   ```jinja
   # Inhalt von config.jinja (mit interner Einrückung):
   {%- if condition -%}
     {%- set value = "test" -%}
   {%- endif -%}
   ```
   
   Wird zu (Marker-Einrückung + interne Einrückung):
   ```yaml
   variables:
     config: >-
       {%- if condition -%}           # ← 8 Leerzeichen (Marker)
         {%- set value = "test" -%}   # ← 8 + 2 = 10 Leerzeichen
       {%- endif -%}                  # ← 8 Leerzeichen (Marker)
   ```

**Warum ist das wichtig?**

- ✅ **YAML ist einrückungssensitiv**: Falsche Einrückung führt zu Syntaxfehlern
- ✅ **Struktur bleibt erhalten**: Die Hierarchie der YAML-Struktur bleibt korrekt
- ✅ **Keine manuelle Anpassung nötig**: Module können ohne Einrückung geschrieben werden
- ✅ **Flexibilität**: Marker kann an beliebiger Position stehen, Einrückung wird automatisch angepasst

### Verzeichnisstruktur

**Ohne `.package` Datei** (Verzeichnisname wird verwendet):
```
example/
├── example_.yaml              # Basisdatei (Input)
├── example.yaml               # Finale Datei (Output, generiert)
├── myBlueprintExample_input.yaml     # Input-Definitionen
├── myBlueprintExample_trigger.yaml   # Trigger-Logik
└── myBlueprintExample_var_*.jinja    # Jinja-Variablen
```

**Mit `.package` Datei** (Package-Name bestimmt nur den Output-Namen):
```
example/
├── myBlueprintExample.package  # Bestimmt den finalen Blueprint-Namen (unabhängig von Basisdatei)
├── example_.yaml               # Basisdatei (Input) - immer nach Verzeichnisname
├── myBlueprintExample.yaml    # Finale Datei (Output, generiert) - Name aus .package
├── myBlueprintExample_input.yaml     # Input-Definitionen
├── myBlueprintExample_trigger.yaml   # Trigger-Logik
└── myBlueprintExample_var_*.jinja   # Jinja-Variablen
```

## 🔖 Marker-Syntax

### YAML-Marker

Verwendung in YAML-Dateien:

```yaml
#START-tgMerger=dateiname.yaml
#END-tgMerger
```

**🔑 Wichtig - Einrückungserhaltung:**

Die **Einrückung des Markers** bestimmt, wie der eingefügte Inhalt eingerückt wird. Das Script:
1. Extrahiert die Einrückung (Leerzeichen/Tabs) vor dem Marker
2. Wendet diese Einrückung auf **jede Zeile** des eingefügten Inhalts an
3. Stellt sicher, dass die YAML-Struktur korrekt bleibt

**Beispiel:**
```yaml
blueprint:
  name: My Blueprint

input:
  #START-tgMerger=myBlueprint_input.yaml
  #END-tgMerger
```

In diesem Beispiel hat der Marker **2 Leerzeichen** Einrückung (unter `input:`). Der gesamte Inhalt von `myBlueprint_input.yaml` wird mit diesen 2 Leerzeichen eingerückt eingefügt.

**Beispiel mit tieferer Einrückung:**
```yaml
action:
  - variables:
      config: >-
        {# START-tgMerger=config.jinja #}
        {{- "Error" -}}
        {#END-tgMerger#}
```

Hier hat der Marker **8 Leerzeichen** Einrückung (innerhalb von `variables:`). Der Jinja-Inhalt wird entsprechend eingerückt.

### Jinja-Marker

Verwendung in Jinja-Templates (innerhalb von YAML):

```jinja
{# START-tgMerger=dateiname.jinja #}
{#END-tgMerger#}
```

**Beispiel:**
```yaml
variables:
  observed: >-
    {# START-tgMerger=myBlueprint_var_observed.jinja #}
    {{- ["Error in Merging"] -}}
    {#END-tgMerger#}
```

### Conditional Merge (TRUE-tgMerger)

Ermöglicht Fallback/Override-Mechanismus:

```yaml
#START-tgMerger=production_config.yaml
#TRUE-tgMerger
# Dieser Inhalt wird verwendet, wenn TRUE-tgMerger vorhanden ist
debug: true
test_mode: enabled
#END-tgMerger
```

**Verhalten:**
- **Ohne `TRUE-tgMerger`**: Inhalt von `production_config.yaml` wird eingefügt
- **Mit `TRUE-tgMerger`**: Inhalt zwischen `TRUE-tgMerger` und `END-tgMerger` wird verwendet (überschreibt die Datei)

### Pfad-Referenzen

#### Relative Pfade (innerhalb des Projekts)
```yaml
#START-tgMerger=unterordner/datei.yaml
#END-tgMerger
```

#### Externe Pfade (aus anderen Verzeichnissen)

**Wichtig**: Sie können Dateien aus **beliebigen Verzeichnissen** einbinden, die relativ zum Verzeichnis der Basisdatei (`*_*.yaml`) erreichbar sind. Dies ist besonders nützlich für:

- **Gemeinsame Jinja-Makros**: Wiederverwendbare Template-Funktionen
- **Code-Snippets**: Häufig verwendete Code-Bausteine
- **Shared Libraries**: Gemeinsame Konfigurationen oder Logik

**Beispiel - Makro aus externem Ordner:**
```yaml
variables:
  debug_output: >-
    {# START-tgMerger=../../../myMacros/macro_dumpToHTML.jinja #}
    {{- "Error: Macro not found" -}}
    {#END-tgMerger#}
```

**Beispiel - Code-Snippet aus anderem Projekt:**
```yaml
action:
  #START-tgMerger=../../sharedSnippets/notification_template.yaml
  #END-tgMerger
```

**Pfad-Auflösung:**
- Alle Pfade sind **relativ zum Verzeichnis der Basisdatei** (`*_*.yaml`)
- Verwenden Sie `../` um in übergeordnete Verzeichnisse zu navigieren
- Verwenden Sie `../../` um zwei Ebenen nach oben zu gehen, etc.
- Unterstützt sowohl relative als auch absolute Pfade (wenn absolut angegeben)

**Typische Verzeichnisstruktur:**
```
homeassistant/
├── blueprints/
│   └── automation/
│       └── myBlueprint/
│           └── myBlueprint_.yaml    # Basisdatei
├── myMacros/                           # Externer Makro-Ordner
│   └── macro_dumpToHTML.jinja
└── sharedSnippets/                     # Externe Code-Snippets
    └── notification_template.yaml
```

In diesem Fall würde der Marker in `myBlueprint_.yaml` so aussehen:
```yaml
{# START-tgMerger=../../../myMacros/macro_dumpToHTML.jinja #}
{#END-tgMerger#}
```

## 💻 Verwendung

### Über VS Code/Cursor Extension

#### Methode 1: Toolbar-Button
1. Öffnen Sie eine Home Assistant Blueprint-Datei mit dem Muster `*_*.yaml`
2. Klicken Sie auf den "Save & Merge Home Assistant Blueprint" Button in der Editor-Toolbar
3. Die Datei wird automatisch gespeichert und gemerged

#### Methode 2: Command Palette
1. Öffnen Sie eine Home Assistant Blueprint-Datei mit dem Muster `*_*.yaml`
2. Drücken Sie `Ctrl+Shift+P` (oder `Cmd+Shift+P` auf macOS)
3. Wählen Sie "Save & Merge Home Assistant Blueprint"
4. Die Datei wird automatisch gespeichert und gemerged

#### Methode 3: Status Bar
1. Öffnen Sie eine Home Assistant Blueprint-Datei mit dem Muster `*_*.yaml`
2. Klicken Sie auf den "Merge" Button in der Statusleiste (unten rechts)

### Über Command Line

```bash
# Vom Repository-Root aus (relativer Pfad):
bash tgBlueprintMerger_yaml_jinja.sh /pfad/zu/ihrem/Blueprint/myBlueprint_.yaml

# Oder mit absolutem Pfad zum Script:
bash /pfad/zu/tgBlueprintMerger/tgBlueprintMerger_yaml_jinja.sh \
  /pfad/zu/ihrem/Blueprint/myBlueprint_.yaml
```

### Automatisierung

Sie können das Script auch in andere Workflows integrieren:

```bash
#!/bin/bash
# Alle Blueprints in einem Verzeichnis mergen
SCRIPT_PATH="/pfad/zu/tgBlueprintMerger/tgBlueprintMerger_yaml_jinja.sh"
for file in /pfad/zu/blueprints/*_*.yaml; do
    bash "$SCRIPT_PATH" "$file"
done
```

## 📖 Beispiele

### Beispiel 1: Einfacher Blueprint mit externem Makro

Dieses Beispiel zeigt:
- ✅ Einrückungserhaltung (beachten Sie die korrekte Einrückung im Ergebnis)
- ✅ Einbindung einer externen Datei (Makro aus `myMacros/` Ordner)
- ✅ Zusammengeführte finale Datei

**Verzeichnisstruktur:**
```
homeassistant/
├── blueprints/
│   └── automation/
│       └── myBlueprint/
│           ├── myBlueprint_.yaml          # Basisdatei
│           ├── myBlueprint_input.yaml   # Lokales Modul
│           └── myBlueprint_trigger.yaml # Lokales Modul
└── myMacros/                                 # Externer Ordner
    └── macro_formatMessage.jinja            # Externes Makro
```

**Basisdatei** `myBlueprint_.yaml`:
```yaml
blueprint:
  name: My Blueprint
  domain: automation

input:
  #START-tgMerger=myBlueprint_input.yaml
  #END-tgMerger

trigger:
  #START-tgMerger=myBlueprint_trigger.yaml
  #END-tgMerger

action:
  - variables:
      formatted_message: >-
        {# START-tgMerger=../../../myMacros/macro_formatMessage.jinja #}
        {{- "Error: Macro not found" -}}
        {#END-tgMerger#}
  - service: notify.persistent_notification
    data:
      message: "{{ formatted_message }}"
```

**Lokales Modul** `myBlueprint_input.yaml`:
```yaml
name:
  name: Name
  default: "World"
  selector:
    text:
```

**Lokales Modul** `myBlueprint_trigger.yaml`:
```yaml
- platform: homeassistant
  event: start
```

**Externes Makro** `myMacros/macro_formatMessage.jinja`:
```jinja
{%- macro formatMessage(name) -%}
  {%- set greeting = "Hello, " ~ name ~ "!" -%}
  {{- greeting -}}
{%- endmacro -%}
{{- formatMessage("World") -}}
```

**🔍 Wichtig - Einrückungserhaltung:**

Beachten Sie, dass der Marker in der Basisdatei mit **8 Leerzeichen** eingerückt ist:
```yaml
      formatted_message: >-
        {# START-tgMerger=... #}
```

**Ergebnis** `myBlueprint.yaml` (gemergte Datei):
```yaml
blueprint:
  name: My Blueprint
  domain: automation

input:
  name:
    name: Name
    default: "World"
    selector:
      text:

trigger:
- platform: homeassistant
  event: start

action:
  - variables:
      formatted_message: >-
        {%- macro formatMessage(name) -%}
          {%- set greeting = "Hello, " ~ name ~ "!" -%}
          {{- greeting -}}
        {%- endmacro -%}
        {{- formatMessage("World") -}}
  - service: notify.persistent_notification
    data:
      message: "{{ formatted_message }}"
```

**✅ Einrückungserhaltung erklärt:**

1. Der Marker `{# START-tgMerger=... #}` steht mit **8 Leerzeichen** Einrückung (innerhalb von `variables:`)
2. Das Script extrahiert diese **8 Leerzeichen** als Basis-Einrückung
3. Jede Zeile aus `macro_formatMessage.jinja` wird mit diesen **8 Leerzeichen** versehen
4. Die Makro-Zeilen werden korrekt eingerückt eingefügt, sodass die YAML-Struktur erhalten bleibt

**Ohne Einrückungserhaltung** würde das Ergebnis so aussehen (❌ falsch):
```yaml
action:
  - variables:
      formatted_message: >-
{%- macro formatMessage(name) -%}    # ❌ Keine Einrückung!
  {%- set greeting = "Hello, " ~ name ~ "!" -%}
  {{- greeting -}}
{%- endmacro -%}
```

**Mit Einrückungserhaltung** (✅ korrekt):
```yaml
action:
  - variables:
      formatted_message: >-
        {%- macro formatMessage(name) -%}    # ✅ Korrekte Einrückung!
          {%- set greeting = "Hello, " ~ name ~ "!" -%}
          {{- greeting -}}
        {%- endmacro -%}
```

### Beispiel 2: Verschachtelte Merges

**Basisdatei** `myBlueprint_.yaml`:
```yaml
action:
  #START-tgMerger=myBlueprint_action.yaml
  #END-tgMerger
```

**Modul** `myBlueprint_action.yaml`:
```yaml
- variables:
    debug: >-
      {# START-tgMerger=myBlueprint_debug.jinja #}
      {{- "Error" -}}
      {#END-tgMerger#}
```

**Modul** `myBlueprint_debug.jinja`:
```jinja
{%- set msg = "Debug Message" -%}
{{- msg -}}
```

**Ergebnis**: Beide Merges werden rekursiv verarbeitet.

### Beispiel 3: Jinja-Variablen

**Basisdatei** `myBlueprint_.yaml`:
```yaml
variables:
  observed_entities: >-
    {# START-tgMerger=myBlueprint_var_observed.jinja #}
    {{- [] -}}
    {#END-tgMerger#}
```

**Modul** `myBlueprint_var_observed.jinja`:
```jinja
{%- set ns = namespace(entities = []) -%}
{%- set ns.entities = ns.entities + ["sensor.temperature"] -%}
{%- set ns.entities = ns.entities + ["sensor.humidity"] -%}
{{- ns.entities -}}
```

### Beispiel 4: Conditional Merge

**Basisdatei** `myBlueprint_.yaml`:
```yaml
variables:
  #START-tgMerger=production_config.yaml
  #TRUE-tgMerger
  # Development Fallback
  debug_mode: true
  log_level: "debug"
  #END-tgMerger
```

**Ergebnis**: Der Inline-Inhalt wird verwendet, nicht die Datei `production_config.yaml`.

## 🌍 Internationalisierung (i18n)

tgBlueprintMerger unterstützt die automatische Übersetzung von Blueprints in mehrere Sprachen.

### Konfiguration

Erstellen Sie eine `.package` Datei im Blueprint-Verzeichnis:

```yaml
LANG=[de,en,it]
DEFAULT_LANG=de
```

- **LANG**: Liste der unterstützten Sprachen (ISO 639-1 Codes, z.B. `de`, `en`, `it`)
- **DEFAULT_LANG**: Standard-Sprache (wird ohne Sprach-Suffix generiert)

### i18n-Marker-Syntax

Verwenden Sie `&i18n:ID:Fallback Text&` in Ihren Blueprint-Dateien:

```yaml
blueprint:
  name: &i18n:10001:My Example Blueprint&
  description: &i18n:10002:Ein Beispiel-Blueprint für tgBlueprintMerger&
  domain: automation
  input:
    name:
      name: &i18n:10003:Name&
      description: &i18n:10004:Name der Automatisierung&
```

**Marker-Format:**
- `&i18n:ID:Fallback Text&`
- **ID**: Eindeutige Text-ID (Zahl, z.B. `10001`)
- **Fallback Text**: Standard-Text, der verwendet wird, wenn keine Übersetzung gefunden wird

### Übersetzungsdateien

Erstellen Sie ein `translations/` Verzeichnis im Blueprint-Verzeichnis:

```
myBlueprint/
├── myBlueprint_.yaml
├── myBlueprint.package
├── translations/
│   ├── de.yaml    # Deutsche Übersetzungen
│   ├── en.yaml    # Englische Übersetzungen
│   └── it.yaml    # Italienische Übersetzungen
```

**Format der Übersetzungsdateien** (`translations/de.yaml`):
```yaml
# German translations
10001: "Mein Beispiel-Blueprint"
10002: "Ein Beispiel-Blueprint für tgBlueprintMerger"
10003: "Name"
10004: "Name der Automatisierung"
```

### Generierte Dateien

Nach dem Merge werden sprachspezifische Dateien generiert:

- **Standard-Sprache** (de): `myBlueprint.yaml` (ohne Suffix)
- **Weitere Sprachen**: `myBlueprint_en.yaml`, `myBlueprint_it.yaml`

### Übersetzungen in Jinja-Templates

i18n-Marker funktionieren auch innerhalb von Jinja-Templates:

```jinja
{%- if enable_debug -%}
  {%- set debug_msg = "Debug: " ~ name ~ " &i18n:10007:wurde ausgeführt&" -%}
  {{- debug_msg -}}
{%- else -%}
  {{- name ~ " &i18n:10008:wurde erfolgreich ausgeführt&" -}}
{%- endif -%}
```

### Zentrale Übersetzungsdatenbank

Falls eine Übersetzung nicht im Projekt gefunden wird, wird eine zentrale Datenbank (`i18n_central_db.yaml`) im Repository-Root durchsucht. Gefundene Übersetzungen werden automatisch in das Projekt kopiert.

### Fehlende Übersetzungen

Fehlende Übersetzungen werden in `missing_text-id.txt` protokolliert:

```
10007|wurde ausgeführt
10008|wurde erfolgreich ausgeführt
```

Format: `ID|Fallback Text`

## 📝 Doc-Tag-Filterung

Dokumentationsblöcke werden automatisch aus dem Output entfernt:

**YAML-Doc-Tags:**
```yaml
#Doc-Start
# Diese Dokumentation wird entfernt
#Doc-End
```

**Jinja-Doc-Tags:**
```jinja
{#Doc-Start#}
{# Diese Dokumentation wird entfernt #}
{#Doc-End#}
```

Die Doc-Tags können auch in derselben Zeile wie anderer Text stehen - die gesamte Zeile wird entfernt.

## 🔧 Hooks

Das System unterstützt Pre- und Post-Merge Hooks für erweiterte Funktionalität.

### Pre-Merge Hook

Erstellen Sie `hook_premerge.sh` im Blueprint-Verzeichnis:

```bash
#!/bin/bash
# hook_premerge.sh
BASEFILE="$1"
OUTPUTFILE="$2"

echo "Pre-merge: Validating $BASEFILE..."
# Ihre Validierungslogik hier
```

**Verwendung:**
- Wird vor dem Merge-Prozess ausgeführt
- Kann für Validierung, Backup, etc. verwendet werden

### Post-Merge Hook

Erstellen Sie `hook_aftermerge.sh` im Blueprint-Verzeichnis:

```bash
#!/bin/bash
# hook_aftermerge.sh
BASEFILE="$1"
OUTPUTFILE="$2"

echo "Post-merge: Processing $OUTPUTFILE..."
# Ihre Nachbearbeitungslogik hier
# z.B. YAML-Validierung, Formatierung, etc.
```

**Verwendung:**
- Wird nach dem Merge-Prozess ausgeführt
- Kann für Validierung, Formatierung, Deployment, etc. verwendet werden

### Hook aktivieren

1. Erstellen Sie die Hook-Datei im Blueprint-Verzeichnis
2. Machen Sie sie ausführbar:
   ```bash
   chmod +x hook_premerge.sh
   chmod +x hook_aftermerge.sh
   ```
3. Das Script erkennt und führt sie automatisch aus

## 🏗️ Architektur

### Komponenten

```
tgBlueprintMerger/
├── tgBlueprintMerger_yaml_jinja.sh    # Core Merge-Script (Bash)
└── tgBlueprintMergerExtension/               # VS Code Extension
    ├── extension.js                # Extension-Logik (Node.js)
    ├── package.json                # Extension-Manifest
    └── README.md                   # Extension-Dokumentation
```

### Merge-Algorithmus

1. **Initialisierung**
   - Basisdatei wird geladen
   - Temporäre Dateien werden erstellt
   - Pre-Merge Hook wird ausgeführt (falls vorhanden)

2. **Merge-Loop** (bis zu 10 Iterationen)
   - Script sucht nach `tgMerger` Markern
   - Für jeden Marker:
     - **Einrückung wird extrahiert**: Die Leerzeichen/Tabs vor dem Marker werden erfasst
     - Datei wird geladen (lokal oder extern über relativen Pfad)
     - **Einrückung wird angewendet**: Jede Zeile des eingefügten Inhalts erhält die extrahierte Einrückung
     - Inhalt wird an der exakten Marker-Position eingefügt
     - Conditional Merge wird verarbeitet (falls `TRUE-tgMerger` vorhanden)
   - Rekursive Verarbeitung verschachtelter Merges

3. **Finalisierung**
   - Finale Datei wird geschrieben
   - Temporäre Dateien werden gelöscht
   - Post-Merge Hook wird ausgeführt (falls vorhanden)

### Zustandsmaschine

Das Script verwendet eine einfache Zustandsmaschine:

- **REPLACEMARKER=0**: Außerhalb eines Merge-Blocks
- **REPLACEMARKER=1**: Innerhalb eines START-Blocks, Datei wird eingefügt
- **REPLACEMARKER=2**: Nach TRUE-tgMerger, sammelt Inline-Inhalt

### Fehlerbehandlung

- **Fehlende Basisdatei**: Script beendet mit Fehlercode 1
- **Verschachtelte START-Marker**: Fehler wird gemeldet
- **Fehlende Referenzdatei**: Warnung wird ausgegeben, Merge wird fortgesetzt
- **Maximale Rekursionstiefe**: Script beendet nach 10 Iterationen

## 🐛 Troubleshooting

### Problem: Extension-Button erscheint nicht

**Lösung:**
1. Stellen Sie sicher, dass die Datei dem Muster `*_*.yaml` entspricht
2. Überprüfen Sie, ob die Extension aktiviert ist
3. Laden Sie VS Code/Cursor neu (`Ctrl+Shift+P` → "Reload Window")

### Problem: "file not found" Fehler

**Lösung:**
1. Überprüfen Sie den Dateipfad im Marker
2. Stellen Sie sicher, dass die Datei im selben Verzeichnis liegt (oder relativer Pfad korrekt ist)
3. Überprüfen Sie die Dateinamen auf Tippfehler

### Problem: Einrückung ist falsch

**Lösung:**
1. **Die Einrückung wird automatisch aus dem Marker extrahiert** - stellen Sie sicher, dass der Marker an der gewünschten Position steht
2. Der Marker sollte auf der **gleichen Einrückungsebene** stehen, auf der der eingefügte Inhalt erscheinen soll
3. Verwenden Sie **konsistente Einrückung** (Leerzeichen oder Tabs, nicht gemischt)
4. **Beispiel**: Wenn Sie möchten, dass der Inhalt unter `variables:` mit 2 Leerzeichen eingerückt wird, muss der Marker auch mit 2 Leerzeichen eingerückt sein:
   ```yaml
   variables:
     #START-tgMerger=datei.yaml    # ✅ 2 Leerzeichen
     #END-tgMerger
   ```
   Nicht:
   ```yaml
   variables:
   #START-tgMerger=datei.yaml      # ❌ Keine Einrückung
   #END-tgMerger
   ```

### Problem: Merge wird nicht ausgeführt

**Lösung:**
1. Überprüfen Sie, ob das Script ausführbar ist: `chmod +x tgBlueprintMerger_yaml_jinja.sh`
2. Überprüfen Sie die Bash-Version: `bash --version`
3. Führen Sie das Script manuell aus, um Fehlermeldungen zu sehen

### Problem: Verschachtelte Merges funktionieren nicht

**Lösung:**
1. Maximale Rekursionstiefe ist 10
2. Überprüfen Sie auf zirkuläre Referenzen
3. Reduzieren Sie die Verschachtelungstiefe

### Problem: TRUE-tgMerger funktioniert nicht wie erwartet

**Lösung:**
1. `TRUE-tgMerger` muss direkt nach `START-tgMerger` kommen
2. Der Inline-Inhalt zwischen `TRUE-tgMerger` und `END-tgMerger` wird verwendet
3. Die ursprüngliche Datei wird ignoriert, wenn `TRUE-tgMerger` vorhanden ist

### Debug-Modus

Führen Sie das Script mit zusätzlicher Ausgabe aus:

```bash
# Vom Repository-Root aus:
bash -x tgBlueprintMerger_yaml_jinja.sh /pfad/zu/datei_.yaml

# Oder mit absolutem Pfad:
bash -x /pfad/zu/tgBlueprintMerger/tgBlueprintMerger_yaml_jinja.sh /pfad/zu/datei_.yaml
```

Dies zeigt alle ausgeführten Befehle an.

## 🔨 Entwicklung

### Script erweitern

Das Merge-Script ist in Bash geschrieben und kann erweitert werden:

```bash
# Neue Funktionalität hinzufügen
# z.B. in tgBlueprintMerger_yaml_jinja.sh
```

### Extension erweitern

Die VS Code Extension ist in Node.js geschrieben:

```javascript
// Neue Commands hinzufügen in extension.js
vscode.commands.registerCommand('tgMerge.neueFunktion', () => {
    // Ihre Logik
});
```

### Testing

1. Erstellen Sie Test-Blueprints mit verschiedenen Szenarien
2. Führen Sie das Script aus
3. Überprüfen Sie die generierten Dateien
4. Validieren Sie die YAML-Syntax

### Beitragen

1. Forken Sie das Repository
2. Erstellen Sie einen Feature-Branch
3. Implementieren Sie Ihre Änderungen
4. Testen Sie ausführlich
5. Erstellen Sie einen Pull Request

## 📝 Best Practices

### Dateiorganisation

- **Ein Modul pro Datei**: Jede logische Komponente in eine separate Datei
- **Konsistente Namenskonvention**: Verwenden Sie einheitliche Präfixe/Suffixe
- **Dokumentation**: Kommentieren Sie komplexe Module

### Marker-Platzierung

- **🔑 Korrekte Einrückung ist kritisch**: 
  - Der Marker muss **exakt an der Position** stehen, an der der Inhalt eingefügt werden soll
  - Die Einrückung des Markers wird auf **jede Zeile** des eingefügten Inhalts angewendet
  - Beispiel: Wenn der Marker mit 4 Leerzeichen eingerückt ist, wird der gesamte eingefügte Inhalt mit 4 Leerzeichen eingerückt
- **Klare Trennung**: Ein Marker pro Block
- **Keine Verschachtelung**: Vermeiden Sie verschachtelte START-Marker (wird als Fehler erkannt)
- **Externe Dateien**: Verwenden Sie relative Pfade (`../` oder `../../`) für Dateien außerhalb des aktuellen Verzeichnisses

### Wiederverwendbarkeit

- **Gemeinsame Module**: Erstellen Sie wiederverwendbare Komponenten
- **Makros**: Verwenden Sie Jinja-Makros für komplexe Logik
- **Externe Referenzen**: Nutzen Sie relative Pfade für gemeinsame Module

### Performance

- **Vermeiden Sie tiefe Verschachtelung**: Maximal 10 Ebenen
- **Optimieren Sie große Dateien**: Teilen Sie sehr große Module auf
- **Caching**: Nutzen Sie Hooks für Caching-Strategien

## 📄 Lizenz

Dieses Projekt ist für den persönlichen Gebrauch entwickelt worden. Bitte beachten Sie die jeweiligen Lizenzen der verwendeten Komponenten.

## 🙏 Danksagungen

- Home Assistant Community für Inspiration
- VS Code Team für die hervorragende Extension-API
- Alle Beitragenden und Tester

## 📞 Support

Bei Fragen oder Problemen:

1. Überprüfen Sie diese Dokumentation
2. Schauen Sie in die Troubleshooting-Sektion
3. Überprüfen Sie die Fehlermeldungen im Output-Channel (VS Code)
4. Führen Sie das Script manuell aus für detaillierte Fehlermeldungen

## 🔄 Changelog

### Version 1.0.0
- Initiale Version
- Basis-Merge-Funktionalität
- VS Code Extension (minimale Wrapper-Extension)
- Unterstützung für YAML und Jinja
- Conditional Merges
- Hook-System
- 🌍 **Internationalisierung (i18n)**: Automatische Übersetzung in mehrere Sprachen
- 📝 **Doc-Tag-Filterung**: Automatisches Entfernen von Dokumentationsblöcken
- 🔧 **Verbesserte Newline-Behandlung**: Module müssen nicht mehr mit Newline enden
- 🧹 **Führende Leerzeilen entfernt**: Saubere Output-Dateien ohne führende Leerzeilen

---

**Entwickelt für modulare Home Assistant Blueprint-Entwicklung** 🏠✨

