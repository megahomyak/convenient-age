#!/bin/bash
set -euo pipefail
ARG="$1"
shift
if [ "$ARG" == "setup" ]; then
    mkdir -p "$CONVENIENT_AGE_STORAGE_DIRECTORY"
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY"
    if [ -d personal ]; then
        echo "already set up" >&2
    else
        mkdir personal
        cd personal
        read -p "Paste private key: " PRIVATE_KEY
        echo "$PRIVATE_KEY" | age -p > priv
        read -p "Paste public key: " PUBLIC_KEY
        echo "$PUBLIC_KEY" > pub
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
elif [ "$ARG" == "list" ]; then
    ls "$CONVENIENT_AGE_STORAGE_DIRECTORY/recipients"
elif [ "$ARG" == "me" ]; then
    cat "$CONVENIENT_AGE_STORAGE_DIRECTORY/personal/pub"
elif [ "$ARG" == "add" ]; then
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY"
    RECIPIENT_PUBLIC_KEY_FILE_NAME="$1"
    shift
    RECIPIENT_PUBLIC_KEY="$1"
    shift
    mkdir -p recipients
    cd recipients
    echo "$RECIPIENT_PUBLIC_KEY" > "$RECIPIENT_PUBLIC_KEY_FILE_NAME"
elif [ "$ARG" == "rm" ]; then
    cd "$CONVENIENT_AGE_STORAGE_DIRECTORY/recipients"
    RECIPIENT_PUBLIC_KEY_FILE_NAME="$1"
    shift
    echo "Deleting $(cat "$(echo "$RECIPIENT_PUBLIC_KEY_FILE_NAME")")"
    rm "$RECIPIENT_PUBLIC_KEY_FILE_NAME"
else
    echo "unknown command" >&2
fi
