#!/bin/bash
set -euo pipefail
cd "$CONVENIENT_AGE_STORAGE_DIRECTORY"
ARG="$1"
shift
if [ "$ARG" == "gen" ]; then
    if [ -f priv ] || [ -f pub ]; then
        echo "personal keys already exist" >&2
    else
        (age-keygen 2>pub) | age -p >priv
    fi
elif [ "$ARG" == "enc" ]; then
    RECIPIENT_KEY_NAME="$1"
    shift
    "$EDITOR" temp
    cat temp | age -e -a -R "recipients/$RECIPIENT_KEY_NAME"
    rm temp
elif [ "$ARG" == "dec" ]; then
    TEMP="$(mktemp)"
    "$EDITOR" temp
    age -d -i <(cat priv | age -d) temp
    rm temp
fi
