#!/bin/bash
set -euo pipefail
ARG="$1"
shift
if [ "$ARG" == "setup" ]; then
    mkdir -p "$CONVENIENT_AGE_STORAGE_DIRECTORY/recipients"
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY"
    if [ -d personal ]; then
        echo "already set up" >&2
    else
        mkdir -p temp_personal
        cd temp_personal
        read -p "Paste private key: " PRIVATE_KEY
        echo "$PRIVATE_KEY" | age -p > priv
        read -p "Paste public key: " PUBLIC_KEY
        echo "$PUBLIC_KEY" > pub
        cd ..
        mv temp_personal personal
    fi
elif [ "$ARG" == "enc" ]; then
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY"
    RECIPIENT_PUBLIC_KEY_FILE_NAME="$1"
    shift
    "$EDITOR" temp
    cat temp | age -e -a -R "recipients/$RECIPIENT_PUBLIC_KEY_FILE_NAME"
    rm temp
elif [ "$ARG" == "dec" ]; then
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY"
    TEMP="$(mktemp)"
    "$EDITOR" temp
    age -d -i <(cat personal/priv | age -d) temp
    rm temp
elif [ "$ARG" == "ls" ]; then
    ls "$CONVENIENT_AGE_STORAGE_DIRECTORY/recipients"
elif [ "$ARG" == "me" ]; then
    cat "$CONVENIENT_AGE_STORAGE_DIRECTORY/personal/pub"
elif [ "$ARG" == "add" ]; then
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY/recipients"
    RECIPIENT_PUBLIC_KEY_FILE_NAME="$1"
    shift
    RECIPIENT_PUBLIC_KEY="$1"
    shift
    echo "$RECIPIENT_PUBLIC_KEY" > "$RECIPIENT_PUBLIC_KEY_FILE_NAME"
elif [ "$ARG" == "rm" ]; then
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY/recipients"
    RECIPIENT_PUBLIC_KEY_FILE_NAME="$1"
    shift
    RECIPIENT_PUBLIC_KEY="$(cat "$RECIPIENT_PUBLIC_KEY_FILE_NAME")"
    echo "Deleting $RECIPIENT_PUBLIC_KEY"
    rm "$RECIPIENT_PUBLIC_KEY_FILE_NAME"
else
    echo "unknown command" >&2
fi
