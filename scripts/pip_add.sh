#!/bin/sh
# =====================================================================
# scripts/pip_add.sh
#
# Purpose:
#   Utility to install Python packages and synchronize requirements.txt.
#   Ensures that newly installed dependencies are captured for 
#   project reproducibility.
#
# Simple Usage:
#   scripts/pip_add.sh requests
#
# Comprehensive Usage:
#   scripts/pip_add.sh requests pyyaml flask
#
# =====================================================================

set -e

# Prevent sourcing (POSIX-compatible check)
# Note: This check works in bash; in pure sh it may not detect sourcing
if [ -n "$BASH_VERSION" ]; then
    if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
        echo "Error: This script is meant to be executed, not sourced."
        echo "Run it as: $0 <pkgs>"
        return 1
    fi
fi

# ---------------------------------------------------------------------
# Preparation: Determine project root and locate the virtual environment.
# ---------------------------------------------------------------------
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
VENV_DIR="$PROJECT_ROOT/.venv"

# ---------------------------------------------------------------------
# Validation: Ensure the virtual environment is already initialized.
# ---------------------------------------------------------------------
if [ ! -d "$VENV_DIR" ]; then
    echo "Error: Virtual environment not found. Please run setup_venv.sh first."
    exit 1
fi

# ---------------------------------------------------------------------
# Execution: Automatically activate the venv if it isn't already.
# ---------------------------------------------------------------------
if [ -z "$VIRTUAL_ENV" ]; then
    # shellcheck disable=SC1091
    . "$VENV_DIR/bin/activate"
fi

# ---------------------------------------------------------------------
# Validation: Ensure at least one package name was provided as an argument.
# ---------------------------------------------------------------------
if [ $# -eq 0 ]; then
    echo "Usage: $0 <pkg1> <pkg2> ..."
    exit 1
fi

# ---------------------------------------------------------------------
# Execution: Install the requested packages and freeze the result to 
# requirements.txt.
# ---------------------------------------------------------------------
echo "Installing dependencies: $@"
pip install "$@"

echo "Updating requirements.txt..."
pip freeze > "$PROJECT_ROOT/requirements.txt"

echo "Done! Packages installed and requirements.txt updated."
