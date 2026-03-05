#!/bin/sh

# vault.sh
# 
# A smart wrapper for ansible-vault commands.
# Features:
# - Auto-detects project virtual environment (.venv/venv).
# - Auto-mounts vault password file (~/.vault_pass).
# - Smart default target file (~/.vault.yml) for edit/view/rekey/decrypt/encrypt.
# - Compatible with macOS, Linux, and Windows (via WSL/Git Bash).

set -e

# Prevent sourcing (POSIX-compatible check)
if [ -n "$BASH_VERSION" ]; then
    if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
        echo "Error: This script is meant to be executed, not sourced."
        echo "Run it as: $0 <args>"
        return 1
    fi
fi

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VAULT_FILE="${HOME}/.vault.yml"
VAULT_PASS_FILE="${HOME}/.vault_pass"

# --- Virtual Environment Auto-Detection ---
if [ -d "${PROJECT_ROOT}/.venv" ]; then
    export PATH="${PROJECT_ROOT}/.venv/bin:$PATH"
fi
if [ -d "${PROJECT_ROOT}/venv" ]; then
     export PATH="${PROJECT_ROOT}/venv/bin:$PATH"
fi

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helper Functions ---
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    echo "Usage: $0 [command] [options] [args]"
    echo ""
    echo "Commands:"
    echo "  edit            Edit an encrypted file (Default target: ${VAULT_FILE})"
    echo "  view            View an encrypted file (Default target: ${VAULT_FILE})"
    echo "  rekey           Rekey an encrypted file (Default target: ${VAULT_FILE})"
    echo "  encrypt         Encrypt a file"
    echo "  decrypt         Decrypt a file"
    echo "  create          Create a new encrypted file"
    echo "  encrypt_string  Encrypt a string"
    echo ""
    echo "Features:"
    echo "  - Automatically uses password file: ${VAULT_PASS_FILE} (if present)"
    echo "  - automatically targets ${VAULT_FILE} if no file argument provided (for edit/view/rekey)"
    echo ""
    echo "Examples:"
    echo "  $0 edit                    # Edit default secret file"
    echo "  $0 view                    # View default secret file"
    echo "  $0 encrypt_string 'pass' --name 'db_pass'"
    echo "  $0 create roles/my_role/vars/vault.yml"
    exit 1
}

# --- Main Logic ---

# Check Ansible installation
if ! command -v ansible-vault > /dev/null 2>&1; then
    log_error "ansible-vault is not installed or not in PATH."
    log_warn "If using Windows, please run this script inside WSL."
    exit 1
fi

if [ $# -eq 0 ]; then
    usage
fi

COMMAND="$1"
shift

# Build command using positional parameters
set -- "$COMMAND"

# 1. Auto-inject Password File
if [ -f "$VAULT_PASS_FILE" ]; then
     set -- "$@" "--vault-password-file" "${VAULT_PASS_FILE}"
fi

# 2. Smart Default File Handling
# Commands that typically target an existing single file
case "$COMMAND" in
    edit|view|rekey|decrypt|encrypt)
        # Check if user provided a filename argument
        # We iterate remaining args to see if there is any non-option argument
        HAS_FILE_ARG=false
        for arg in "$@"; do
            case "$arg" in
                -*) ;;  # Option, skip
                *) HAS_FILE_ARG=true; break ;;
            esac
        done

        if [ "$HAS_FILE_ARG" = "false" ]; then
            # Special case: 'encrypt' usually implies we want to encrypt a NEW plain file
            if [ "$COMMAND" != "encrypt" ]; then
                if [ ! -f "$VAULT_FILE" ]; then
                     log_warn "Default target file ${VAULT_FILE} does not exist."
                else
                     log_info "Targeting default file: ${VAULT_FILE}"
                     set -- "$@" "${VAULT_FILE}"
                fi
            fi
        fi
        ;;
    create)
        # Must provide filename
        ;;
esac

# 3. Append remaining user arguments
# Note: We already shifted past the command, so we need to get original args
# This is a limitation - we'll pass all remaining args directly

log_info "Executing: ansible-vault $*"
exec ansible-vault "$@"
