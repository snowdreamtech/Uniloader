#!/bin/sh
set -eu

# Purpose: Fix permissions for GPG directory and files
# Usage: ./fix-gpg-permissions.sh [directory] (defaults to ~/.gnupg)

# Logic:
# chmod 700 ~/.gnupg
# chmod 600 ~/.gnupg/* (files only, to be safe)
# chmod 700 ~/.gnupg/private-keys-v1.d
# chmod 600 ~/.gnupg/private-keys-v1.d/*

TARGET_DIR="${1:-$HOME/.gnupg}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory $TARGET_DIR does not exist. Skipping."
  exit 0
fi

# 1. Main Directory
chmod 700 "$TARGET_DIR"

# 2. Files in the root of .gnupg (chmod 600)
# We use find to avoid hitting directories (which would break execute permissions)
find "$TARGET_DIR" -maxdepth 1 -type f -exec chmod 600 {} +

# 3. private-keys-v1.d Directory
if [ -d "$TARGET_DIR/private-keys-v1.d" ]; then
  chmod 700 "$TARGET_DIR/private-keys-v1.d"
  find "$TARGET_DIR/private-keys-v1.d" -type f -exec chmod 600 {} +
fi

echo "Fixed permissions for $TARGET_DIR"
