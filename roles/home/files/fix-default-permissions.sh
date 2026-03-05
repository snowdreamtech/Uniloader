#!/bin/sh
set -eu

# Purpose: Fix permissions for specific files in the home directory based on explicitly defined lists.
# Usage: ./fix-default-permissions.sh [directory] (defaults to $HOME)
# Note: POSIX sh compatible (no arrays).

TARGET_DIR="${1:-$HOME}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR does not exist. Skipping."
    exit 0
fi

# ==========================================
# File Lists (Space-separated strings)
# Add filenames here to enforce permissions.
# Files NOT listed here will NOT be touched.
# ==========================================

# Files to set to 600 (Private: Owner read/write only)
FILES_600=".bash_history .zsh_history .mysql_history .psql_history .python_history \
.netrc .pgpass .ds_store .DS_Store .vault_pass .private.key .public.key"

# Files to set to 644 (Public: Owner rw, Group/Others r)
FILES_644=".bashrc .bash_profile .profile .zshrc .gitconfig .vimrc .condarc .npmrc"

# Files to set to 664 (Group Write: Owner rw, Group rw, Others r)
FILES_664=""

# ==========================================
# Logic
# ==========================================

apply_permissions() {
    perm="$1"
    # In POSIX sh, we rely on word splitting of the variable passed as $2
    # So we do NOT quote the second argument in the for loop list.
    file_list="$2"

    for file in $file_list; do
        if [ -z "$file" ]; then continue; fi

        filepath="$TARGET_DIR/$file"

        # Only process if it is a regular file
        if [ -f "$filepath" ]; then
            chmod "$perm" "$filepath"
            # echo "Fixed $filepath -> $perm"
        fi
    done
}

# Apply permissions
# Note: Variables are unquoted here intentionally to allow word splitting (simulating array iteration)
apply_permissions "600" "$FILES_600"
apply_permissions "644" "$FILES_644"
apply_permissions "664" "$FILES_664"

echo "Permission fix complete for explicit files in $TARGET_DIR"
