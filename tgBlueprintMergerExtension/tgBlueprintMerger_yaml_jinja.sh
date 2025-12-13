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
INSERTFILE=""
SPACES=""
LOOPCOUNTER=0


if [ -f "$BASEDIR/$BASEFILE" ]; then
    echo create package $PACKAGE from basefile $BASEFILE
else
    echo package $PACKAGE from basefile $BASEFILE cannot created
    exit 1
fi
touch "$TEMPFILEPRE"
touch "$TEMPFILEPAST"
cp -f "$BASEDIR/$BASEFILE" "$TEMPFILEPAST"

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
    echo "" > $TEMPFILEPAST

    REPLACEMARKER=0
    regexpSTART=".*START-tgMerger.*"
    regexpEND=".*END-tgMerger.*"
    regexpTRUE=".*TRUE-tgMerger.*"
    ifTRUE=""
    while IFS= read -r line
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
                    while IFS= read -r subline
                        do
                        echo "$SPACES$subline" >> $TEMPFILEPAST
                        done < "$INSERTFILE"
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

cp -f "$TEMPFILEPAST" "$OUTPUTFILE"
rm "$TEMPFILEPAST"
rm "$TEMPFILEPRE"

# Execute after-merge hook if it exists
if [ -f "$BASEDIR/hook_aftermerge.sh" ] && [ -x "$BASEDIR/hook_aftermerge.sh" ]; then
    echo "Executing hook_aftermerge.sh"
    (cd "$BASEDIR" && ./hook_aftermerge.sh "$BASEFILE" "$OUTPUTFILE")
fi
