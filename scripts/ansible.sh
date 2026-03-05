#!/bin/sh

# Set default values
INVENTORY="localhost"
PLAYBOOK="orchestrator"
VERBOSITY=""
VAULT_VARS="@$HOME/.vault.yml"
VAULT_PASS="$HOME/.vault_pass"

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --inventory <name>    Inventory name (default: localhost -> inventory/localhost.yml)"
    echo "  -p, --playbook <name>     Playbook name (default: orchestrator -> playbooks/orchestrator.yml)"
    echo "  -v                        Verbosity level (default: none, supports -v, -vv, -vvv, etc.)"
    echo "  --vault-vars <file>       Path to vault vars file (default: ~/.vault.yml)"
    echo "  --vault-pass <file>       Path to vault password file (default: ~/.vault_pass)"
    echo "  -e, --extra-vars <vars>   Additional extra vars"
    echo "  --home-action <action>    Home role action (encrypt, decrypt, restore). Sets playbook to 'home'."
    echo "  --home-files <files>      Comma-separated list of files for home role action."
    echo "  -h, --help                Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -i staging -p deploy -vv"
}

# Parse arguments and store extra args
EXTRA_ARGS=""
while [ $# -gt 0 ]; do
    case $1 in
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -p|--playbook)
            PLAYBOOK="$2"
            shift 2
            ;;
        -v|-vv|-vvv|-vvvv)
            VERBOSITY="$1"
            shift
            ;;
        --vault-vars)
            VAULT_VARS="$2"
            shift 2
            ;;
        --vault-pass)
            VAULT_PASS="$2"
            shift 2
            ;;
        -e|--extra-vars)
            EXTRA_ARGS="$EXTRA_ARGS -e \"$2\""
            shift 2
            ;;
        --home-action)
            HOME_ACTION="$2"
            PLAYBOOK="home"
            shift 2
            ;;
        --home-files)
            HOME_FILES_RAW="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            # Pass through any other arguments
            EXTRA_ARGS="$EXTRA_ARGS \"$1\""
            shift
            ;;
    esac
done

# Resolve inventory path
case "$INVENTORY" in
    */*)
        INVENTORY_PATH="$INVENTORY"
        ;;
    *)
        INVENTORY_PATH="inventory/${INVENTORY}.yml"
        ;;
esac

# Resolve playbook path
case "$PLAYBOOK" in
    */*)
        PLAYBOOK_PATH="$PLAYBOOK"
        ;;
    *)
        case "$PLAYBOOK" in
            *.yml)
                PLAYBOOK_PATH="playbooks/${PLAYBOOK}"
                ;;
            *)
                PLAYBOOK_PATH="playbooks/${PLAYBOOK}.yml"
                ;;
        esac
        ;;
esac

# Ensure paths exist
if [ ! -f "$INVENTORY_PATH" ]; then
    echo "Error: Inventory file '$INVENTORY_PATH' not found."
    exit 1
fi

if [ ! -f "$PLAYBOOK_PATH" ]; then
    echo "Error: Playbook file '$PLAYBOOK_PATH' not found."
    exit 1
fi

# Ensure virtual environment is activated
SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$PROJECT_ROOT/.venv/bin/activate" ]; then
    . "$PROJECT_ROOT/.venv/bin/activate"
else
    if [ -f "$PROJECT_ROOT/scripts/setup_venv.sh" ]; then
        echo "Virtual environment not found. Attempting to create one..."
        . "$PROJECT_ROOT/scripts/setup_venv.sh"
    else
        echo "Error: Virtual environment not found and setup script missing."
        exit 1
    fi
fi

# Process Home Role arguments if present
if [ -n "$HOME_ACTION" ]; then
    EXTRA_ARGS="$EXTRA_ARGS -e \"home_action=$HOME_ACTION\""
fi

if [ -n "$HOME_FILES_RAW" ]; then
    # Convert comma-separated to JSON list: "file1,file2" -> "file1","file2"
    # We use sed to replace commas with quote-comma-quote
    FORMATTED_FILES=$(echo "$HOME_FILES_RAW" | sed 's/,/","/g')
    # Wrap in JSON array syntax and single quotes for the complex argument
    EXTRA_ARGS="$EXTRA_ARGS -e '{\"home_files\": [\"$FORMATTED_FILES\"]}'"
fi

# Execute ansible-playbook with all arguments
# Using eval to properly handle quoted arguments in EXTRA_ARGS
echo "Running: ansible-playbook -i \"$INVENTORY_PATH\" \"$PLAYBOOK_PATH\" $VERBOSITY -e \"$VAULT_VARS\" --vault-password-file \"$VAULT_PASS\" $EXTRA_ARGS"
echo "----------------------------------------------------------------"

eval ansible-playbook -i \""$INVENTORY_PATH"\" \""$PLAYBOOK_PATH"\" "$VERBOSITY" -e \""$VAULT_VARS"\" --vault-password-file \""$VAULT_PASS"\" "$EXTRA_ARGS"
