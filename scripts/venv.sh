#!/bin/sh
# =====================================================================
# scripts/venv.sh
#
# Purpose:
#   POSIX-compatible Python virtual environment (venv) manager.
#   Provides functions to activate, deactivate, recreate, and inspect
#   the local venv.
#
# Simple Usage:
#   . scripts/venv.sh on
#
# Comprehensive Usage:
#   . scripts/venv.sh recreate
#   . scripts/venv.sh status
#   . scripts/venv.sh off
#
# =====================================================================

# ---------------------------------------------------------------------
# Validation: Ensure the script is sourced into the current shell.
# Direct execution will not affect the environment.
# ---------------------------------------------------------------------
if [ "$0" = "$BASH_SOURCE" ] 2>/dev/null || [ "$0" = "$ZSH_NAME" ] 2>/dev/null; then
    echo "Usage: . scripts/venv.sh <command>"
    exit 1
fi

VENV_DIR=".venv"

# ---------------------------------------------------------------------
# Mode: on - Activate the virtual environment.
# ---------------------------------------------------------------------
venv_on() {
    if [ ! -d "$VENV_DIR" ]; then
        echo "Virtual environment not found. Creating..."
        python3 -m venv "$VENV_DIR"
    fi
    . "$VENV_DIR/bin/activate"
    echo "Venv activated."
}

# ---------------------------------------------------------------------
# Mode: off - Deactivate the active virtual environment.
# ---------------------------------------------------------------------
venv_off() {
    if command -v deactivate >/dev/null 2>&1; then
        deactivate
        echo "Venv deactivated."
    else
        echo "Venv is not active."
    fi
}

# ---------------------------------------------------------------------
# Mode: recreate - Completely remove and re-initialize the venv.
# ---------------------------------------------------------------------
venv_recreate() {
    echo "Recreating venv..."
    rm -rf "$VENV_DIR"
    python3 -m venv "$VENV_DIR"
    echo "Venv recreated."
}

# ---------------------------------------------------------------------
# Mode: status - Report whether a venv is currently active.
# ---------------------------------------------------------------------
venv_status() {
    if command -v deactivate >/dev/null 2>&1; then
        echo "Venv is active."
    else
        echo "Venv is not active."
    fi
}

# ---------------------------------------------------------------------
# Mode: path - Display the relative path to the venv directory.
# ---------------------------------------------------------------------
venv_path() {
    echo "$VENV_DIR"
}

# ---------------------------------------------------------------------
# Dispatch: Process the command-line argument to trigger the
# corresponding function.
# ---------------------------------------------------------------------
case "$1" in
    on) venv_on ;;
    off) venv_off ;;
    recreate) venv_recreate ;;
    status) venv_status ;;
    path) venv_path ;;
    *)
        echo "Usage: . scripts/venv.sh {on|off|recreate|status|path}"
        ;;
esac
