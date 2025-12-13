# tgBlueprintMerger - Home Assistant Blueprint Merger

> **Language**: [🇩🇪 Deutsch](README.md) | 🇬🇧 English

A modular build system for Home Assistant Blueprints that allows you to split complex blueprint files into clear, reusable modules and automatically merge them into a final blueprint file.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Concepts](#concepts)
- [Marker Syntax](#marker-syntax)
- [Usage](#usage)
- [Examples](#examples)
- [Hooks](#hooks)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [Development](#development)

## 🎯 Overview

**tgBlueprintMerger** is a build tool for Home Assistant Blueprints that enables modular development of complex automations. Instead of maintaining one large, unwieldy YAML file, you can split your blueprints into logical modules:

- **Input Definitions** → `*_input.yaml`
- **Trigger Logic** → `*_trigger.yaml`
- **Conditions** → `*_condition.yaml`
- **Actions** → `*_action.yaml`
- **Jinja Templates** → `*_var_*.jinja`
- **Debug Code** → `*_debug_*.yaml`

The system automatically merges these modules into a final, Home Assistant-compatible blueprint file.

## ✨ Features

### Core Functionality
- ✅ **Modular System**: Split blueprints into reusable components
- ✅ **Automatic Merging**: Merge multiple files into a final blueprint
- ✅ **Nested Merges**: Support for recursive merge operations (up to 10 levels)
- ✅ **🔑 Indentation Preservation**: **Critical feature** - The inserted content is inserted **exactly at the marker's indentation position**. The marker's indentation is extracted and applied to every line of the inserted content, ensuring the YAML structure remains correct.
- ✅ **YAML & Jinja**: Support for both file formats
- ✅ **Conditional Merges**: Fallback mechanism with `TRUE-tgMerger` markers
- ✅ **External Files**: Include files from other directories (e.g., shared Jinja macros, code snippets)

### VS Code/Cursor Integration
- 🎨 **Toolbar Button**: Direct access via editor toolbar
- 📊 **Status Bar**: Quick access via status bar
- ⌨️ **Command Palette**: Available via `Ctrl+Shift+P`
- 💾 **Auto-Save**: Automatic saving before merge
- 📝 **Progress Feedback**: Visual feedback during the merging process

### Advanced Features
- 🔧 **Pre/Post Hooks**: Executable scripts before/after merge
- 🔄 **Recursive Processing**: Automatic processing of nested merges
- ⚠️ **Error Handling**: Detailed error messages for problems
- 📁 **Path Support**: Relative and absolute paths for external files

## 🚀 Installation

### Prerequisites

- **Bash**: Must be available on the system (default on Linux/macOS)
- **VS Code or Cursor**: For extension integration
- **Node.js**: For VS Code Extension (usually installed with VS Code)

### Step 1: Clone or download repository

```bash
# Clone repository
git clone https://github.com/YourUsername/tgBlueprintMerger.git
cd tgBlueprintMerger

# Or if you already have the repository:
cd /path/to/your/tgBlueprintMerger
```

### Step 2: Install VS Code Extension

**Note**: The script `tgBlueprintMerger_yaml_jinja.sh` is already included in the extension and will be made executable automatically. You don't need to install or configure it separately.

1. Install the VSIX file:
   - `Ctrl+Shift+P` → "Extensions: Install from VSIX"
   - Select the file `tg-merge-blueprint-1.0.0.vsix` from the repository root

### Step 3: Configuration (Optional)

**Important**: The script `tgBlueprintMerger_yaml_jinja.sh` is already included in the extension and is used automatically. You don't need to install it separately.

The extension searches for the script in the following order:
1. **Extension Directory** (Default) - The script is automatically made executable
2. **Configured Path** (if set in settings)
3. **Workspace Root**
4. **Parent Directories** (up to 10 levels)

If you want to use a custom path:

1. Open settings: `Ctrl+,` (or `Cmd+,` on macOS)
2. Search for `tgBlueprintMerger.scriptPath`
3. Enter the path to the script:
   - **Absolute Path**: `/path/to/tgBlueprintMerger_yaml_jinja.sh`
   - **Relative Path**: `tgBlueprintMerger_yaml_jinja.sh` (relative to workspace root)
   - **Leave empty**: Automatic search is used (recommended)

### Step 4: Verification

1. Open a Home Assistant Blueprint file with the pattern `*_*.yaml` (e.g., `myBlueprint_.yaml`)
2. You should see the "Save & Merge Home Assistant Blueprint" button in the toolbar
3. Test the merge process

## 🏃 Quick Start

### Example: Simple Home Assistant Blueprint

1. **Create a directory** `myBlueprint/` and a base file `myBlueprint_.yaml` in it:
   **Important**: The filename must match the directory name (with `_` before `.yaml`)
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

2. **Create the module files**:

   `myBlueprint_input.yaml`:
   ```yaml
   test_input:
     name: Test Input
     default: "Hello"
     selector:
       text:
   ```

   `myBlueprint_trigger.yaml`:
   ```yaml
   - platform: state
     entity_id: input_text.test
   ```

3. **Execute the merge**:
   - Open **any file** in the `myBlueprint/` directory (e.g., `myBlueprint_input.yaml`)
   - Save the file
   - Click the "Save & Merge Home Assistant Blueprint" button
   - Or: `Ctrl+Shift+P` → "Save & Merge Home Assistant Blueprint"
   - **Note**: The extension automatically finds the base file `myBlueprint_.yaml` based on the directory name

4. **Result**: The file `myBlueprint.yaml` is created in the `myBlueprint/` directory with all modules merged.

**Optional - With `.package` file:**
- Create a file `customName.package` in the `myBlueprint/` directory
- The final file will then be named `customName.yaml` (instead of `myBlueprint.yaml`)
- The base file remains `myBlueprint_.yaml` (based on directory name)

## 📚 Concepts

### Filename Convention

The system uses a special naming convention based on the **directory name**:

#### Base File Name Derived from Directory Name

**Important**: The base file name is **always** derived from the directory name where the blueprint files are located.

- **Base File**: `[directoryname]_.yaml` (with underscore before `.yaml`)
  - The directory name determines the base file name
  - Example: Directory `example/` → Base file: `example_.yaml`
  - Example: Directory `myBlueprint/` → Base file: `myBlueprint_.yaml`

#### Final File (Output)

- **Without `.package` file**: The directory name is also used for the final file
  - Example: Directory `example/` → Output: `example.yaml`
  
- **With `.package` file**: The `.package` file name determines the final blueprint name
  - The `.package` file can have **any name** (independent of directory or base file name)
  - Example: Directory `example/` with `myBlueprintExample.package` → Output: `myBlueprintExample.yaml`
  - This allows you to choose the final blueprint name independently of the directory name

#### Summary

| Scenario | Directory | Base File | `.package` File | Final File |
|----------|-----------|-----------|------------------|------------|
| Standard | `example/` | `example_.yaml` | - | `example.yaml` |
| With Package | `example/` | `example_.yaml` | `myBlueprintExample.package` | `myBlueprintExample.yaml` |

#### Module Files

- **Module Files**: Can be named arbitrarily, referenced via markers
  - Example: `myBlueprintExample_input.yaml`, `myBlueprintExample_trigger.yaml`
  - Module files can have any names, don't need to match directory or package name

### Merge Process

1. **Directory Analysis**: 
   - The script determines the directory name of the passed file
   - The base file is searched as `[directoryname]_.yaml`
   - If a `.package` file exists, its name is used for the final file
   
2. **Input**: Base file `[directoryname]_.yaml` is read
   - The base file must be in the same directory as the passed file
   
3. **Parsing**: Script searches for `tgMerger` markers in the base file
   
4. **Indentation Extraction**: **Critical step** - The indentation (spaces/tabs) before the marker is captured
   
5. **Resolving**: Referenced files are loaded (local or external via relative path)
   - All paths are relative to the base file's directory
   
6. **Merging**: File contents are inserted:
   - **Every line** of the inserted content receives the extracted indentation
   - Indentation is **additively** applied (marker indentation + any internal indentation of the file)
   
7. **Recursion**: Nested merges are processed recursively (up to 10 levels)
   
8. **Output**: Final file is created:
   - **Without `.package` file**: `[directoryname].yaml`
   - **With `.package` file**: `[package-name].yaml` (name from `.package` file)

### 🔑 Indentation Preservation - The Heart of the System

**Indentation preservation** is one of the most important features of tgMerge. It ensures that the YAML structure remains correct after merging.

**How it works:**

1. **Marker Position Determines Indentation:**
   ```yaml
   variables:
     config: >-
       {# START-tgMerger=config.jinja #}    # ← 8 spaces indentation
       {#END-tgMerger#}
   ```
   The script recognizes: "The marker has 8 spaces indentation"

2. **Indentation is Applied to Every Line:**
   ```jinja
   # Content of config.jinja (without indentation):
   {%- set value = "test" -%}
   {{- value -}}
   ```
   
   Becomes (with 8 spaces):
   ```yaml
   variables:
     config: >-
       {%- set value = "test" -%}    # ← 8 spaces added
       {{- value -}}                 # ← 8 spaces added
   ```

3. **Internal Indentation is Preserved:**
   If the inserted file already has indentation, it is preserved:
   ```jinja
   # Content of config.jinja (with internal indentation):
   {%- if condition -%}
     {%- set value = "test" -%}
   {%- endif -%}
   ```
   
   Becomes (marker indentation + internal indentation):
   ```yaml
   variables:
     config: >-
       {%- if condition -%}           # ← 8 spaces (marker)
         {%- set value = "test" -%}   # ← 8 + 2 = 10 spaces
       {%- endif -%}                  # ← 8 spaces (marker)
   ```

**Why is this important?**

- ✅ **YAML is indentation-sensitive**: Wrong indentation leads to syntax errors
- ✅ **Structure is preserved**: The YAML structure hierarchy remains correct
- ✅ **No manual adjustment needed**: Modules can be written without indentation
- ✅ **Flexibility**: Marker can be at any position, indentation is automatically adjusted

### Directory Structure

**Without `.package` file** (directory name is used):
```
example/
├── example_.yaml              # Base file (Input)
├── example.yaml               # Final file (Output, generated)
├── myBlueprintExample_input.yaml     # Input definitions
├── myBlueprintExample_trigger.yaml   # Trigger logic
└── myBlueprintExample_var_*.jinja    # Jinja variables
```

**With `.package` file** (package name determines only the output name):
```
example/
├── myBlueprintExample.package  # Determines final blueprint name (independent of base file)
├── example_.yaml               # Base file (Input) - always by directory name
├── myBlueprintExample.yaml    # Final file (Output, generated) - name from .package
├── myBlueprintExample_input.yaml     # Input definitions
├── myBlueprintExample_trigger.yaml   # Trigger logic
└── myBlueprintExample_var_*.jinja   # Jinja variables
```

## 🔖 Marker Syntax

### YAML Marker

Usage in YAML files:

```yaml
#START-tgMerger=filename.yaml
#END-tgMerger
```

**🔑 Important - Indentation Preservation:**

The **marker's indentation** determines how the inserted content is indented. The script:
1. Extracts the indentation (spaces/tabs) before the marker
2. Applies this indentation to **every line** of the inserted content
3. Ensures the YAML structure remains correct

**Example:**
```yaml
blueprint:
  name: My Blueprint

input:
  #START-tgMerger=myBlueprint_input.yaml
  #END-tgMerger
```

In this example, the marker has **2 spaces** indentation (under `input:`). The entire content of `myBlueprint_input.yaml` is inserted with these 2 spaces indentation.

**Example with deeper indentation:**
```yaml
action:
  - variables:
      config: >-
        {# START-tgMerger=config.jinja #}
        {{- "Error" -}}
        {#END-tgMerger#}
```

Here the marker has **8 spaces** indentation (within `variables:`). The Jinja content is indented accordingly.

### Jinja Marker

Usage in Jinja templates (within YAML):

```jinja
{# START-tgMerger=filename.jinja #}
{#END-tgMerger#}
```

**Example:**
```yaml
variables:
  observed: >-
    {# START-tgMerger=myBlueprint_var_observed.jinja #}
    {{- ["Error in Merging"] -}}
    {#END-tgMerger#}
```

### Conditional Merge (TRUE-tgMerger)

Enables fallback/override mechanism:

```yaml
#START-tgMerger=production_config.yaml
#TRUE-tgMerger
# This content is used when TRUE-tgMerger is present
debug: true
test_mode: enabled
#END-tgMerger
```

**Behavior:**
- **Without `TRUE-tgMerger`**: Content from `production_config.yaml` is inserted
- **With `TRUE-tgMerger`**: Content between `TRUE-tgMerger` and `END-tgMerger` is used (overrides the file)

### Path References

#### Relative Paths (within project)
```yaml
#START-tgMerger=subfolder/file.yaml
#END-tgMerger
```

#### External Paths (from other directories)

**Important**: You can include files from **any directories** that are reachable relative to the base file's directory (`*_*.yaml`). This is particularly useful for:

- **Shared Jinja Macros**: Reusable template functions
- **Code Snippets**: Frequently used code blocks
- **Shared Libraries**: Common configurations or logic

**Example - Macro from external folder:**
```yaml
variables:
  debug_output: >-
    {# START-tgMerger=../../../myMacros/macro_dumpToHTML.jinja #}
    {{- "Error: Macro not found" -}}
    {#END-tgMerger#}
```

**Example - Code snippet from another project:**
```yaml
action:
  #START-tgMerger=../../sharedSnippets/notification_template.yaml
  #END-tgMerger
```

**Path Resolution:**
- All paths are **relative to the base file's directory** (`*_*.yaml`)
- Use `../` to navigate to parent directories
- Use `../../` to go up two levels, etc.
- Supports both relative and absolute paths (when absolutely specified)

**Typical Directory Structure:**
```
homeassistant/
├── blueprints/
│   └── automation/
│       └── myBlueprint/
│           └── myBlueprint_.yaml    # Base file
├── myMacros/                           # External macro folder
│   └── macro_dumpToHTML.jinja
└── sharedSnippets/                     # External code snippets
    └── notification_template.yaml
```

In this case, the marker in `myBlueprint_.yaml` would look like:
```yaml
{# START-tgMerger=../../../myMacros/macro_dumpToHTML.jinja #}
{#END-tgMerger#}
```

## 💻 Usage

### Via VS Code/Cursor Extension

#### Method 1: Toolbar Button
1. Open a Home Assistant Blueprint file with the pattern `*_*.yaml`
2. Click the "Save & Merge Home Assistant Blueprint" button in the editor toolbar
3. The file is automatically saved and merged

#### Method 2: Command Palette
1. Open a Home Assistant Blueprint file with the pattern `*_*.yaml`
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
3. Select "Save & Merge Home Assistant Blueprint"
4. The file is automatically saved and merged

#### Method 3: Status Bar
1. Open a Home Assistant Blueprint file with the pattern `*_*.yaml`
2. Click the "Merge" button in the status bar (bottom right)

### Via Command Line

```bash
# From repository root (relative path):
bash tgBlueprintMerger_yaml_jinja.sh /path/to/your/Blueprint/myBlueprint_.yaml

# Or with absolute path to script:
bash /path/to/tgBlueprintMerger/tgBlueprintMerger_yaml_jinja.sh \
  /path/to/your/Blueprint/myBlueprint_.yaml
```

### Automation

You can also integrate the script into other workflows:

```bash
#!/bin/bash
# Merge all blueprints in a directory
SCRIPT_PATH="/path/to/tgBlueprintMerger/tgBlueprintMerger_yaml_jinja.sh"
for file in /path/to/blueprints/*_*.yaml; do
    bash "$SCRIPT_PATH" "$file"
done
```

## 📖 Examples

### Example 1: Simple Blueprint with External Macro

This example shows:
- ✅ Indentation preservation (note the correct indentation in the result)
- ✅ Inclusion of an external file (macro from `myMacros/` folder)
- ✅ Merged final file

**Directory Structure:**
```
homeassistant/
├── blueprints/
│   └── automation/
│       └── myBlueprint/
│           ├── myBlueprint_.yaml          # Base file
│           ├── myBlueprint_input.yaml   # Local module
│           └── myBlueprint_trigger.yaml # Local module
└── myMacros/                                 # External folder
    └── macro_formatMessage.jinja            # External macro
```

**Base File** `myBlueprint_.yaml`:
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

**Local Module** `myBlueprint_input.yaml`:
```yaml
name:
  name: Name
  default: "World"
  selector:
    text:
```

**Local Module** `myBlueprint_trigger.yaml`:
```yaml
- platform: homeassistant
  event: start
```

**External Macro** `myMacros/macro_formatMessage.jinja`:
```jinja
{%- macro formatMessage(name) -%}
  {%- set greeting = "Hello, " ~ name ~ "!" -%}
  {{- greeting -}}
{%- endmacro -%}
{{- formatMessage("World") -}}
```

**🔍 Important - Indentation Preservation:**

Note that the marker in the base file has **8 spaces** indentation:
```yaml
      formatted_message: >-
        {# START-tgMerger=... #}
```

**Result** `myBlueprint.yaml` (merged file):
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

**✅ Indentation Preservation Explained:**

1. The marker `{# START-tgMerger=... #}` has **8 spaces** indentation (within `variables:`)
2. The script extracts these **8 spaces** as base indentation
3. Every line from `macro_formatMessage.jinja` is prefixed with these **8 spaces**
4. The macro lines are correctly indented when inserted, so the YAML structure is preserved

**Without Indentation Preservation** the result would look like this (❌ wrong):
```yaml
action:
  - variables:
      formatted_message: >-
{%- macro formatMessage(name) -%}    # ❌ No indentation!
  {%- set greeting = "Hello, " ~ name ~ "!" -%}
  {{- greeting -}}
{%- endmacro -%}
```

**With Indentation Preservation** (✅ correct):
```yaml
action:
  - variables:
      formatted_message: >-
        {%- macro formatMessage(name) -%}    # ✅ Correct indentation!
          {%- set greeting = "Hello, " ~ name ~ "!" -%}
          {{- greeting -}}
        {%- endmacro -%}
```

### Example 2: Nested Merges

**Base File** `myBlueprint_.yaml`:
```yaml
action:
  #START-tgMerger=myBlueprint_action.yaml
  #END-tgMerger
```

**Module** `myBlueprint_action.yaml`:
```yaml
- variables:
    debug: >-
      {# START-tgMerger=myBlueprint_debug.jinja #}
      {{- "Error" -}}
      {#END-tgMerger#}
```

**Module** `myBlueprint_debug.jinja`:
```jinja
{%- set msg = "Debug Message" -%}
{{- msg -}}
```

**Result**: Both merges are processed recursively.

### Example 3: Jinja Variables

**Base File** `myBlueprint_.yaml`:
```yaml
variables:
  observed_entities: >-
    {# START-tgMerger=myBlueprint_var_observed.jinja #}
    {{- [] -}}
    {#END-tgMerger#}
```

**Module** `myBlueprint_var_observed.jinja`:
```jinja
{%- set ns = namespace(entities = []) -%}
{%- set ns.entities = ns.entities + ["sensor.temperature"] -%}
{%- set ns.entities = ns.entities + ["sensor.humidity"] -%}
{{- ns.entities -}}
```

### Example 4: Conditional Merge

**Base File** `myBlueprint_.yaml`:
```yaml
variables:
  #START-tgMerger=production_config.yaml
  #TRUE-tgMerger
  # Development Fallback
  debug_mode: true
  log_level: "debug"
  #END-tgMerger
```

**Result**: The inline content is used, not the file `production_config.yaml`.

## 🔧 Hooks

The system supports pre- and post-merge hooks for advanced functionality.

### Pre-Merge Hook

Create `hook_premerge.sh` in the blueprint directory:

```bash
#!/bin/bash
# hook_premerge.sh
BASEFILE="$1"
OUTPUTFILE="$2"

echo "Pre-merge: Validating $BASEFILE..."
# Your validation logic here
```

**Usage:**
- Executed before the merge process
- Can be used for validation, backup, etc.

### Post-Merge Hook

Create `hook_aftermerge.sh` in the blueprint directory:

```bash
#!/bin/bash
# hook_aftermerge.sh
BASEFILE="$1"
OUTPUTFILE="$2"

echo "Post-merge: Processing $OUTPUTFILE..."
# Your post-processing logic here
# e.g., YAML validation, formatting, etc.
```

**Usage:**
- Executed after the merge process
- Can be used for validation, formatting, deployment, etc.

### Activate Hooks

1. Create the hook file in the blueprint directory
2. Make it executable:
   ```bash
   chmod +x hook_premerge.sh
   chmod +x hook_aftermerge.sh
   ```
3. The script detects and executes them automatically

## 🏗️ Architecture

### Components

```
tgBlueprintMerger/
├── tgBlueprintMerger_yaml_jinja.sh    # Core Merge Script (Bash)
└── tgBlueprintMergerExtension/               # VS Code Extension
    ├── extension.js                # Extension Logic (Node.js)
    ├── package.json                # Extension Manifest
    └── README.md                   # Extension Documentation
```

### Merge Algorithm

1. **Initialization**
   - Base file is loaded
   - Temporary files are created
   - Pre-merge hook is executed (if present)

2. **Merge Loop** (up to 10 iterations)
   - Script searches for `tgMerger` markers
   - For each marker:
     - **Indentation is extracted**: Spaces/tabs before the marker are captured
     - File is loaded (local or external via relative path)
     - **Indentation is applied**: Every line of the inserted content receives the extracted indentation
     - Content is inserted at the exact marker position
     - Conditional merge is processed (if `TRUE-tgMerger` is present)
   - Recursive processing of nested merges

3. **Finalization**
   - Final file is written
   - Temporary files are deleted
   - Post-merge hook is executed (if present)

### State Machine

The script uses a simple state machine:

- **REPLACEMARKER=0**: Outside a merge block
- **REPLACEMARKER=1**: Inside a START block, file is being inserted
- **REPLACEMARKER=2**: After TRUE-tgMerger, collecting inline content

### Error Handling

- **Missing Base File**: Script exits with error code 1
- **Nested START Markers**: Error is reported
- **Missing Reference File**: Warning is issued, merge continues
- **Maximum Recursion Depth**: Script exits after 10 iterations

## 🐛 Troubleshooting

### Problem: Extension Button Doesn't Appear

**Solution:**
1. Make sure the file matches the pattern `*_*.yaml`
2. Check if the extension is enabled
3. Reload VS Code/Cursor (`Ctrl+Shift+P` → "Reload Window")

### Problem: "file not found" Error

**Solution:**
1. Check the file path in the marker
2. Make sure the file is in the same directory (or relative path is correct)
3. Check filenames for typos

### Problem: Indentation is Wrong

**Solution:**
1. **Indentation is automatically extracted from the marker** - make sure the marker is at the desired position
2. The marker should be at the **same indentation level** where the inserted content should appear
3. Use **consistent indentation** (spaces or tabs, not mixed)
4. **Example**: If you want the content under `variables:` to be indented with 2 spaces, the marker must also be indented with 2 spaces:
   ```yaml
   variables:
     #START-tgMerger=file.yaml    # ✅ 2 spaces
     #END-tgMerger
   ```
   Not:
   ```yaml
   variables:
   #START-tgMerger=file.yaml      # ❌ No indentation
   #END-tgMerger
   ```

### Problem: Merge is Not Executed

**Solution:**
1. Check if the script is executable: `chmod +x tgBlueprintMerger_yaml_jinja.sh`
2. Check the Bash version: `bash --version`
3. Run the script manually to see error messages

### Problem: Nested Merges Don't Work

**Solution:**
1. Maximum recursion depth is 10
2. Check for circular references
3. Reduce nesting depth

### Problem: TRUE-tgMerger Doesn't Work as Expected

**Solution:**
1. `TRUE-tgMerger` must come directly after `START-tgMerger`
2. The inline content between `TRUE-tgMerger` and `END-tgMerger` is used
3. The original file is ignored when `TRUE-tgMerger` is present

### Debug Mode

Run the script with additional output:

```bash
# From repository root:
bash -x tgBlueprintMerger_yaml_jinja.sh /path/to/file_.yaml

# Or with absolute path:
bash -x /path/to/tgBlueprintMerger/tgBlueprintMerger_yaml_jinja.sh /path/to/file_.yaml
```

This shows all executed commands.

## 🔨 Development

### Extending the Script

The merge script is written in Bash and can be extended:

```bash
# Add new functionality
# e.g., in tgBlueprintMerger_yaml_jinja.sh
```

### Extending the Extension

The VS Code Extension is written in Node.js:

```javascript
// Add new commands in extension.js
vscode.commands.registerCommand('tgMerge.newFunction', () => {
    // Your logic
});
```

### Testing

1. Create test blueprints with various scenarios
2. Run the script
3. Check the generated files
4. Validate YAML syntax

### Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Test thoroughly
5. Create a Pull Request

## 📝 Best Practices

### File Organization

- **One Module per File**: Each logical component in a separate file
- **Consistent Naming Convention**: Use uniform prefixes/suffixes
- **Documentation**: Comment complex modules

### Marker Placement

- **🔑 Correct Indentation is Critical**: 
  - The marker must be **exactly at the position** where the content should be inserted
  - The marker's indentation is applied to **every line** of the inserted content
  - Example: If the marker is indented with 4 spaces, the entire inserted content is indented with 4 spaces
- **Clear Separation**: One marker per block
- **No Nesting**: Avoid nested START markers (detected as error)
- **External Files**: Use relative paths (`../` or `../../`) for files outside the current directory

### Reusability

- **Shared Modules**: Create reusable components
- **Macros**: Use Jinja macros for complex logic
- **External References**: Use relative paths for shared modules

### Performance

- **Avoid Deep Nesting**: Maximum 10 levels
- **Optimize Large Files**: Split very large modules
- **Caching**: Use hooks for caching strategies

## 📄 License

This project has been developed for personal use. Please note the respective licenses of the components used.

## 🙏 Acknowledgments

- Home Assistant Community for inspiration
- VS Code Team for the excellent Extension API
- All contributors and testers

## 📞 Support

For questions or problems:

1. Check this documentation
2. Look in the Troubleshooting section
3. Check error messages in the Output channel (VS Code)
4. Run the script manually for detailed error messages

## 🔄 Changelog

### Version 1.0.0
- Initial version
- Basic merge functionality
- VS Code Extension
- Support for YAML and Jinja
- Conditional Merges
- Hook System

---

**Developed for modular Home Assistant Blueprint development** 🏠✨
