#!/bin/bash

YML=".yaml"
SEPERA="_"
MYNAME="$(basename $1 )"
BASEDIR="$(dirname $1)"

# Base file is always determined by directory name
DIRNAME="$(basename $BASEDIR )"
BASEFILE="$DIRNAME$SEPERA$YML"

# Output file name: use .package file if exists, otherwise use directory name
PACKAGE="$DIRNAME"
if ls "$BASEDIR"/*.package 1> /dev/null 2>&1; then
    # Get the first .package file found
    PACKAGEFILE="$(ls "$BASEDIR"/*.package | head -n 1)"
    PACKAGE="$(basename "$PACKAGEFILE" .package)"
fi

OUTPUTFILE="$BASEDIR/$PACKAGE$YML"
TEMPFILEPRE="$BASEDIR/tmp1"
TEMPFILEPAST="$BASEDIR/tmp0"
TEMPFILEFILTERED="$BASEDIR/tmp_filtered"
INSERTFILE=""
SPACES=""
LOOPCOUNTER=0

# Function to filter out Doc-Tags and their content
# Removes lines between #Doc-Start/#Doc-End (YAML) and {#Doc-Start#}/{#Doc-End#} (Jinja)
filter_doc_tags() {
    local input_file="$1"
    local output_file="$2"
    
    > "$output_file"
    
    local in_doc_block=0
    # Match lines containing #Doc-Start or #Doc-End (even with additional text)
    local yaml_doc_start=".*#Doc-Start.*"
    local yaml_doc_end=".*#Doc-End.*"
    local jinja_doc_start=".*\{#Doc-Start#\}.*"
    local jinja_doc_end=".*\{#Doc-End#\}.*"
    
    while IFS= read -r line || [ -n "$line" ]
    do
        # Check for YAML Doc-Tags
        if [[ $line =~ $yaml_doc_start ]]; then
            in_doc_block=1
            continue
        elif [[ $line =~ $yaml_doc_end ]]; then
            in_doc_block=0
            continue
        fi
        
        # Check for Jinja Doc-Tags
        if [[ $line =~ $jinja_doc_start ]]; then
            in_doc_block=1
            continue
        elif [[ $line =~ $jinja_doc_end ]]; then
            in_doc_block=0
            continue
        fi
        
        # Only output lines that are not in a doc block
        if [ $in_doc_block -eq 0 ]; then
            echo "$line" >> "$output_file"
        fi
    done < "$input_file"
}


if [ -f "$BASEDIR/$BASEFILE" ]; then
    echo create package $PACKAGE from basefile $BASEFILE
else
    echo package $PACKAGE from basefile $BASEFILE cannot created
    exit 1
fi
touch "$TEMPFILEPRE"
touch "$TEMPFILEPAST"
# Filter Doc-Tags from base file before processing
filter_doc_tags "$BASEDIR/$BASEFILE" "$TEMPFILEPAST"

# Execute pre-merge hook if it exists
if [ -f "$BASEDIR/hook_premerge.sh" ] && [ -x "$BASEDIR/hook_premerge.sh" ]; then
    echo "Executing hook_premerge.sh"
    (cd "$BASEDIR" && ./hook_premerge.sh "$BASEFILE" "$OUTPUTFILE")
fi

# WHILE GREP ...
while grep -q 'tgMerger' "$TEMPFILEPAST" && [[ $LOOPCOUNTER -lt 10 ]]
    do
    ((LOOPCOUNTER++))
    echo "LOOPCOUNTER: $LOOPCOUNTER"

    cp -f "$TEMPFILEPAST" "$TEMPFILEPRE"
    > $TEMPFILEPAST

    REPLACEMARKER=0
    regexpSTART=".*START-tgMerger.*"
    regexpEND=".*END-tgMerger.*"
    regexpTRUE=".*TRUE-tgMerger.*"
    ifTRUE=""
    while IFS= read -r line || [ -n "$line" ]
        do
            if [[ $line =~ $regexpSTART && $REPLACEMARKER -gt 0 ]]; then
                echo there is an error in your structure
                exit 1
            elif [[ $line =~ $regexpSTART ]]; then
                REPLACEMARKER=1
                [[ "$line" =~ ^([[:space:]]*).*=([a-zA-Z0-9_./]+) ]] && SPACES="${BASH_REMATCH[1]}" && file="${BASH_REMATCH[2]}"
                if [ -f "$BASEDIR/$file" ]; then
                    INSERTFILE="$BASEDIR/$file"
                    echo "import $INSERTFILE"
                    # Filter out Doc-Tags before inserting
                    filter_doc_tags "$INSERTFILE" "$TEMPFILEFILTERED"
                    file_has_content=false
                    while IFS= read -r subline || [ -n "$subline" ]
                        do
                        if [ -n "$subline" ]; then
                            echo "$SPACES$subline" >> $TEMPFILEPAST
                            file_has_content=true
                        fi
                        done < "$TEMPFILEFILTERED"
                    # Ensure newline after inserted file content to separate from next module
                    if [ "$file_has_content" = true ]; then
                        echo "" >> $TEMPFILEPAST
                    fi
                else
                    echo "$file not found"
                fi
            elif [[ $line =~ $regexpTRUE && $REPLACEMARKER -eq 1 ]]; then
                REPLACEMARKER=2
            elif [[ $line =~ $regexpEND ]]; then
                INSERTFILE=""
                SPACES=""
                if [[ $REPLACEMARKER -eq 2 ]]; then
                    echo "$ifTRUE" >> $TEMPFILEPAST
                fi
                REPLACEMARKER=0
                ifTRUE=""
            elif [[ $REPLACEMARKER -eq 2 ]]; then
                ifTRUE="$ifTRUE$line"
            elif [[ $REPLACEMARKER -eq 0 ]]; then
                echo "$line" >> $TEMPFILEPAST
            elif [[ $REPLACEMARKER -eq 1 && $INSERTFILE == "" ]]; then
                echo "$line" >> $TEMPFILEPAST
            fi
        
        done < "$TEMPFILEPRE"
    done

# Remove leading empty lines from output file
if [ -f "$TEMPFILEPAST" ]; then
    # Remove only leading blank lines (lines with only whitespace at the start)
    # Use awk to skip leading empty lines
    awk '/^[[:space:]]*$/ && !found {next} {found=1; print}' "$TEMPFILEPAST" > "$TEMPFILEPAST.tmp" && mv "$TEMPFILEPAST.tmp" "$TEMPFILEPAST"
    # If file is now empty or only whitespace, restore from original
    if [ ! -s "$TEMPFILEPAST" ]; then
        cp -f "$BASEDIR/$BASEFILE" "$TEMPFILEPAST"
    fi
fi

cp -f "$TEMPFILEPAST" "$OUTPUTFILE"

# ============================================================================
# Internationalization (i18n) Processing
# ============================================================================

# Function to parse package file and extract languages
parse_package_file() {
    local package_file="$1"
    local default_lang=""
    local languages=()
    
    if [ -f "$package_file" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            # Parse LANG=[de,en,it] format
            if [[ $line =~ ^LANG=\[(.*)\]$ ]]; then
                local lang_list="${BASH_REMATCH[1]}"
                # Split by comma and add to array
                IFS=',' read -ra LANG_ARRAY <<< "$lang_list"
                for lang in "${LANG_ARRAY[@]}"; do
                    # Trim whitespace
                    lang=$(echo "$lang" | xargs)
                    languages+=("$lang")
                done
            # Parse DEFAULT_LANG=de format
            elif [[ $line =~ ^DEFAULT_LANG=(.*)$ ]]; then
                default_lang="${BASH_REMATCH[1]}"
                default_lang=$(echo "$default_lang" | xargs)
            fi
        done < "$package_file"
    fi
    
    # If no DEFAULT_LANG specified, use first language
    if [ -z "$default_lang" ] && [ ${#languages[@]} -gt 0 ]; then
        default_lang="${languages[0]}"
    fi
    
    echo "${languages[@]}"
    echo "DEFAULT:$default_lang"
}

# Function to load translation from YAML file
load_translation_file() {
    local translation_file="$1"
    local text_id="$2"
    
    if [ -f "$translation_file" ]; then
        # Use awk to extract value for text_id from YAML
        # Format: "12345: "Text""
        awk -v id="$text_id" -F': ' '
            /^[0-9]+:/ {
                current_id = $1
                gsub(/:/, "", current_id)
                if (current_id == id) {
                    # Remove quotes and leading/trailing spaces
                    value = $2
                    gsub(/^["'\'']|["'\'']$/, "", value)
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                    print value
                    exit
                }
            }
        ' "$translation_file"
    fi
}

# Function to load from central database
load_from_central_db() {
    local db_file="$1"
    local text_id="$2"
    local lang="$3"
    
    if [ -f "$db_file" ]; then
        # YAML format: "12345: { de: "Text", en: "Text" }"
        awk -v id="$text_id" -v lang="$lang" -F': ' '
            /^[0-9]+:/ {
                current_id = $1
                gsub(/:/, "", current_id)
                if (current_id == id) {
                    # Look for the language in the value
                    rest = $0
                    sub(/^[^:]+:[[:space:]]*/, "", rest)
                    # Try to find lang: "text" pattern
                    pattern = lang "[[:space:]]*:[[:space:]]*[\"'\''][^\"'\'']+[\"'\'']"
                    if (match(rest, pattern)) {
                        value = substr(rest, RSTART, RLENGTH)
                        sub(/^[^:]+:[[:space:]]*[\"'\'']/, "", value)
                        sub(/[\"'\'']$/, "", value)
                        print value
                        exit
                    }
                }
            }
        ' "$db_file"
    fi
}

# Function to extract all i18n markers from file
extract_i18n_markers() {
    local input_file="$1"
    local markers_file="$2"
    
    > "$markers_file"
    
    # Pattern: &i18n:12345:Text&
    local i18n_pattern="&i18n:([0-9]+):([^&]+)&"
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Check if line contains i18n marker
        if [[ $line =~ $i18n_pattern ]]; then
            local text_id="${BASH_REMATCH[1]}"
            local fallback_text="${BASH_REMATCH[2]}"
            echo "$text_id|$fallback_text" >> "$markers_file"
        fi
    done < "$input_file"
    
    # Remove duplicates
    if [ -f "$markers_file" ]; then
        sort -u "$markers_file" > "${markers_file}.tmp" && mv "${markers_file}.tmp" "$markers_file"
    fi
}

# Function to replace i18n markers with translations
replace_i18n_markers() {
    local input_file="$1"
    local output_file="$2"
    local lang="$3"
    local project_translations_dir="$4"
    local central_db_file="$5"
    local missing_file="$6"
    
    # If input and output are the same file, use a temporary file
    local temp_output=""
    if [ "$input_file" = "$output_file" ]; then
        temp_output=$(mktemp)
        local actual_output="$output_file"
    else
        temp_output="$output_file"
    fi
    
    > "$temp_output"
    
    local i18n_pattern="&i18n:([0-9]+):([^&]+)&"
    
    while IFS= read -r line || [ -n "$line" ]; do
        local new_line="$line"
        local max_iterations=100
        local iteration=0
        
        # Replace all i18n markers in the line (handle multiple markers per line)
        while [[ $new_line =~ $i18n_pattern ]] && [ $iteration -lt $max_iterations ]; do
            ((iteration++))
            local text_id="${BASH_REMATCH[1]}"
            local fallback_text="${BASH_REMATCH[2]}"
            local translation=""
            
            # Try project translation file first
            local project_translation_file="$project_translations_dir/${lang}.yaml"
            if [ -f "$project_translation_file" ]; then
                translation=$(load_translation_file "$project_translation_file" "$text_id")
            fi
            
            # If not found, try central database
            if [ -z "$translation" ] && [ -f "$central_db_file" ]; then
                translation=$(load_from_central_db "$central_db_file" "$text_id" "$lang")
                
                # If found in central DB, add to project translation file
                if [ -n "$translation" ]; then
                    # Create translations directory if it doesn't exist
                    mkdir -p "$project_translations_dir"
                    # Append to translation file (simple append, no deduplication)
                    echo "$text_id: \"$translation\"" >> "$project_translation_file"
                    echo "Added translation $text_id from central DB to project"
                fi
            fi
            
            # Use translation or fallback
            if [ -n "$translation" ]; then
                local replacement="$translation"
            else
                local replacement="$fallback_text"
                # Add to missing translations file (only once per text_id)
                if ! grep -q "^${text_id}|" "$missing_file" 2>/dev/null; then
                    echo "$text_id|$fallback_text" >> "$missing_file"
                fi
            fi
            
            # Escape special characters in fallback_text for replacement
            local escaped_fallback="${fallback_text//\//\\/}"
            escaped_fallback="${escaped_fallback//\*/\\*}"
            escaped_fallback="${escaped_fallback//\[/\\[}"
            escaped_fallback="${escaped_fallback//\]/\\]}"
            
            # Replace marker with translation/fallback using sed for reliability
            local marker_pattern="&i18n:${text_id}:${escaped_fallback}&"
            new_line=$(echo "$new_line" | sed "s|${marker_pattern}|${replacement}|g")
        done
        
        echo "$new_line" >> "$temp_output"
    done < "$input_file"
    
    # If we used a temporary file, move it to the output
    if [ -n "$actual_output" ]; then
        mv "$temp_output" "$actual_output"
    fi
}

# Process i18n if package file exists and contains LANG
if [ -f "$BASEDIR/$PACKAGE.package" ]; then
    PACKAGEFILE="$BASEDIR/$PACKAGE.package"
    
    # Parse package file directly
    languages=()
    default_lang=""
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Parse LANG=[de,en,it] format
        if [[ $line =~ ^LANG=\[(.*)\]$ ]]; then
            lang_list="${BASH_REMATCH[1]}"
            # Split by comma and add to array
            IFS=',' read -ra LANG_ARRAY <<< "$lang_list"
            for lang in "${LANG_ARRAY[@]}"; do
                # Trim whitespace
                lang=$(echo "$lang" | xargs)
                languages+=("$lang")
            done
        # Parse DEFAULT_LANG=de format
        elif [[ $line =~ ^DEFAULT_LANG=(.*)$ ]]; then
            default_lang="${BASH_REMATCH[1]}"
            default_lang=$(echo "$default_lang" | xargs)
        fi
    done < "$PACKAGEFILE"
    
    # If no DEFAULT_LANG specified, use first language
    if [ -z "$default_lang" ] && [ ${#languages[@]} -gt 0 ]; then
        default_lang="${languages[0]}"
    fi
    
    # If languages are defined, process i18n
    if [ ${#languages[@]} -gt 0 ]; then
        echo "Processing i18n for languages: ${languages[*]}"
        
        # Paths for translations
        PROJECT_TRANSLATIONS_DIR="$BASEDIR/translations"
        MERGER_DIR="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")"
        CENTRAL_DB_FILE="$MERGER_DIR/i18n_central_db.yaml"
        MISSING_FILE="$BASEDIR/missing_text-id.txt"
        
        # Create central DB if it doesn't exist
        if [ ! -f "$CENTRAL_DB_FILE" ]; then
            touch "$CENTRAL_DB_FILE"
            echo "# Central i18n Database" >> "$CENTRAL_DB_FILE"
            echo "# Format: text_id: { lang: \"translation\" }" >> "$CENTRAL_DB_FILE"
        fi
        
        # Create a copy of the merged file with i18n markers for processing
        # (since we'll overwrite OUTPUTFILE for the default language)
        I18N_SOURCE_FILE="$BASEDIR/tmp_i18n_source.yaml"
        cp "$OUTPUTFILE" "$I18N_SOURCE_FILE"
        
        # Extract all i18n markers from merged file
        MARKERS_FILE="$BASEDIR/tmp_i18n_markers.txt"
        extract_i18n_markers "$I18N_SOURCE_FILE" "$MARKERS_FILE"
        
        # Process each language
        for lang in "${languages[@]}"; do
            # Determine output filename
            if [ "$lang" = "$default_lang" ]; then
                lang_output_file="$OUTPUTFILE"
            else
                # Add language suffix: myBlueprint_en.yaml
                lang_output_file="${OUTPUTFILE%.yaml}_${lang}.yaml"
            fi
            
            echo "Generating translation for language: $lang -> $lang_output_file"
            
            # Replace i18n markers with translations (use source file with markers)
            replace_i18n_markers "$I18N_SOURCE_FILE" "$lang_output_file" "$lang" \
                "$PROJECT_TRANSLATIONS_DIR" "$CENTRAL_DB_FILE" "$MISSING_FILE"
        done
        
        # Clean up temporary source file
        rm -f "$I18N_SOURCE_FILE"
        
        # Clean up
        rm -f "$MARKERS_FILE"
        
        # Report missing translations
        if [ -f "$MISSING_FILE" ] && [ -s "$MISSING_FILE" ]; then
            missing_count=$(wc -l < "$MISSING_FILE" | xargs)
            echo "Warning: $missing_count missing translations found. See $MISSING_FILE"
        fi
    fi
fi

rm -f "$TEMPFILEPAST"
rm -f "$TEMPFILEPRE"
rm -f "$TEMPFILEFILTERED"

# Execute after-merge hook if it exists
if [ -f "$BASEDIR/hook_aftermerge.sh" ] && [ -x "$BASEDIR/hook_aftermerge.sh" ]; then
    echo "Executing hook_aftermerge.sh"
    (cd "$BASEDIR" && ./hook_aftermerge.sh "$BASEFILE" "$OUTPUTFILE")
fi
