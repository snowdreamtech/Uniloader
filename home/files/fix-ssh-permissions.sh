#!/usr/bin/env sh
set -eu

# Purpose: Fix permissions for SSH directory and files
# Usage: ./fix-ssh-permissions.sh [directory] (defaults to ~/.ssh)

# Logic:
# chmod 700 ~/.ssh
# chmod 700 ~/.ssh/controlpath
# chmod 600 ~/.ssh/id_*
# chmod 644 ~/.ssh/*.pub
# chmod 600 ~/.ssh/authorized_keys 2>/dev/null

TARGET_DIR="${1:-$HOME/.ssh}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR does not exist. Skipping."
    exit 0
fi

# 1. Directory permissions
chmod 700 "$TARGET_DIR"

# 1.1 Controlpath permissions
if [ ! -d "$TARGET_DIR/controlpath" ]; then
    mkdir -p "$TARGET_DIR/controlpath"
fi
chmod 700 "$TARGET_DIR/controlpath"

# 2. File permissions
# Use find to list files, then apply logic based on filename
find "$TARGET_DIR" -maxdepth 1 -type f | while read -r f; do
    filename=$(basename "$f")

    case "$filename" in
        *.pub)
            # Public keys: 644
            chmod 644 "$f"
            ;;
        id_*)
            # Private keys: 600
            [ -f "$f" ] || return 0 # Ensure file exists before processing
            # Note: id_*.pub is caught by *.pub case above if named standardly.
            # If a public key is named 'id_rsa.key', it falls here => 600 (Safe).
            chmod 600 "$f"
            ;;
        authorized_keys*)
            # Authorized keys: 600
            chmod 600 "$f"
            ;;
        *.conf|config|config.base|known_hosts)
            # SSH config and known_hosts: 600
            chmod 600 "$f"
            ;;
        *.sh|*.bash|*.zsh|*.bat|*.ps1)
            # Scripts: 700
            chmod 700 "$f"
            ;;
        *)
            # Default safe permission for other files in .ssh
            chmod 600 "$f"
            ;;
    esac
done

echo "Fixed permissions for $TARGET_DIR"
