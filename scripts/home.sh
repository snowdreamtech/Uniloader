#!/bin/sh

# home.sh
#
# A unified wrapper script for managing GPG-encrypted home secrets using Ansible.
# Supports: Encrypt, Decrypt, Restore workflows.
# Compatible with macOS, Linux, and Windows (via WSL/Git Bash).

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
PLAYBOOK="${PROJECT_ROOT}/playbooks/home.yml"
DEFAULT_INVENTORY="${PROJECT_ROOT}/inventory"
VAULT_FILE="${HOME}/.uniloader/.vault.yml"
VAULT_PASS_FILE="${HOME}/.uniloader/.vault_pass"

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
    echo "Usage: $0 [action] [options]"
    echo ""
    echo "Actions:"
    echo "  restore       Deploy and restore secrets to target hosts (Default)"
    echo "  decrypt       Decrypt GPG files in-place on target hosts"
    echo "  encrypt       Encrypt plaintext files on target hosts for backup"
    echo ""
    echo "Options:"
    echo "  -i, --inventory <path>   Specify inventory file or directory (Default: detect in inventory/)"
    echo "  -l, --limit <host>       Limit execution to specific host(s)"
    echo "  -v, --verbose            Enable verbose output"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 restore -i inventory/prod.yml"
    echo "  $0 decrypt -l dev_machine"
    exit 1
}

ensure_gpg_unlocked() {
    local action="$1"

    # Encryption usually only needs the public key, so we can skip unlocking for 'encrypt'
    if [ "$action" = "encrypt" ]; then
       return 0
    fi

    log_info "Checking GPG key status for action '${action}'..."

    # Recipient checking omitted for brevity, focusing on unlocking.
    # Check if already unlocked
    if echo "test" | gpg --batch --no-tty --clearsign --output /dev/null 2>/dev/null; then
       log_info "GPG key is already unlocked."
       return 0
    fi

    # Strategy 1: Unlock using Environment Variable (CI/CD / Vault injected)
    if [ -n "$GPG_PASSPHRASE" ]; then
       log_info "GPG_PASSPHRASE detected. Attempting non-interactive unlock..."
       if echo "test" | gpg --batch --no-tty --pinentry-mode loopback --passphrase "$GPG_PASSPHRASE" --clearsign --output /dev/null 2>/dev/null; then
            log_info "GPG key successfully unlocked via environment variable."
            return 0
       else
            log_warn "Failed to unlock using GPG_PASSPHRASE. Falling back to interactive mode..."
       fi
    fi

    # Strategy 2: Interactive Unlock (Local Development)
    log_warn "GPG key is locked. Attempting to unlock via GPG Agent (Interactive)..."

    if echo "test" | gpg --clearsign --output /dev/null > /dev/null 2>&1; then
        log_info "GPG key successfully unlocked."
    else
        log_error "Failed to unlock GPG key. Cannot proceed with '${action}'."
        log_error "Hint: To run non-interactively, set the 'GPG_PASSPHRASE' environment variable."
        exit 1
    fi
}

# --- Main Logic ---

if ! command -v ansible-playbook > /dev/null 2>&1; then
    log_error "Ansible is not installed or not in PATH."
    log_warn "On Windows, please use WSL."
    exit 1
fi

# Parse Arguments
ACTION=""
INVENTORY=""
LIMIT=""
VERBOSE=""

# First argument detection
if [ $# -gt 0 ]; then
    case "$1" in
       restore|decrypt|encrypt)
           ACTION="$1"
           shift
           ;;
       -h|--help)
           usage
           ;;
       -*)
           # Valid options, imply default 'restore'
           ;;
       *)
           log_error "Unknown action: $1"
           usage
           ;;
    esac
fi

# Parse Options
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
       -i|--inventory)
           INVENTORY="$2"
           shift 2
           ;;
       -l|--limit)
           LIMIT="$2"
           shift 2
           ;;
       -v|--verbose)
           VERBOSE="-v"
           shift
           ;;
       -h|--help)
           usage
           ;;
       *)
           log_error "Unknown argument: $1"
           usage
           ;;
    esac
done

if [ -z "$ACTION" ]; then
    log_warn "No action specified, defaulting to 'restore'."
    ACTION="restore"
fi

# --- Execution Flow ---

# Detect Inventory
if [ -z "$INVENTORY" ]; then
    if [ -f "${DEFAULT_INVENTORY}/hosts" ]; then
       INVENTORY="${DEFAULT_INVENTORY}/hosts"
    elif [ -d "${DEFAULT_INVENTORY}" ]; then
       COUNT=$(find "${DEFAULT_INVENTORY}" -maxdepth 1 -name "*.yml" -o -name "*.yaml" | wc -l)
       if [ "$COUNT" -eq 1 ]; then
            INVENTORY=$(find "${DEFAULT_INVENTORY}" -maxdepth 1 -name "*.yml" -o -name "*.yaml" | head -n 1)
       elif [ "$COUNT" -gt 1 ]; then
            log_error "Multiple inventory files found in ${DEFAULT_INVENTORY}. Please specify one with -i."
            exit 1
       else
            log_warn "No inventory file specified and none found. Ansible might fail."
       fi
    fi
fi

# Build command using positional parameters
set -- "ansible-playbook" "${PLAYBOOK}"

if [ -n "$INVENTORY" ]; then set -- "$@" "-i" "${INVENTORY}"; fi
if [ -n "$LIMIT" ]; then set -- "$@" "-l" "${LIMIT}"; fi
if [ -n "$VERBOSE" ]; then set -- "$@" "${VERBOSE}"; fi

set -- "$@" "-e" "home_action=${ACTION}"

# --- Vault Integration ---
# Automatically inject vault secrets if present, ensuring playbook can run headless
if [ -f "$VAULT_FILE" ]; then
    set -- "$@" "-e" "@${VAULT_FILE}"
    log_info "Using Vault secrets from: ${VAULT_FILE}"
fi

if [ -f "$VAULT_PASS_FILE" ]; then
    set -- "$@" "--vault-password-file" "${VAULT_PASS_FILE}"
    log_info "Using Vault password from: ${VAULT_PASS_FILE}"
fi

# Ensure GPG is unlocked
ensure_gpg_unlocked "${ACTION}"

log_info "Executing: $*"
"$@"
