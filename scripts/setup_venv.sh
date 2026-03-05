#!/bin/sh
# =====================================================================
# File: scripts/setup_venv.sh
# Author: snowdream
# Purpose:
#   Bootstraps a Python virtual environment (.venv) for the project,
#   configures an optimized pip mirror (Tsinghua), and installs all
#   required dependencies from requirements.txt.
#
# Simple Usage:
#   . scripts/setup_venv.sh
#
# Comprehensive Usage:
#   # To troubleshoot dependency issues during setup:
#   DEBUG=1 . scripts/setup_venv.sh
#
# Note:
#   This script MUST be sourced to ensure the environment variables
#   (PATH, VIRTUAL_ENV) carry over to your current shell session.
# =====================================================================

set -e

# ---------------------------------------------------------------------
# Guard: Ensure the script is being sourced, not executed directly.
# ---------------------------------------------------------------------
if [ -n "$BASH_VERSION" ]; then
    # shellcheck disable=SC3028,SC2128
    if [ "${BASH_SOURCE:-}" = "${0}" ]; then
        echo "Usage: . scripts/setup_venv.sh"
        exit 1
    fi
fi

# ---------------------------------------------------------------------
# Path Discovery: Determine project root based on script location.
# ---------------------------------------------------------------------
# In CI environments (like GitHub Actions), sourcing a script overwrites $0 with
# a temporary runner script path, breaking `dirname "$0"`.
# We fallback to using the caller's $PROJECT_ROOT or $PWD as the root if applicable.
if [ -z "$PROJECT_ROOT" ] || [ ! -f "$PROJECT_ROOT/requirements.txt" ]; then
    if [ -f "requirements.txt" ] && [ -d "scripts" ]; then
        PROJECT_ROOT="$PWD"
    else
        echo "Error: Cannot determine project root."
        echo "Please source this script from the root of the repository."
        echo "Example: . scripts/setup_venv.sh"
        return 1 2>/dev/null || exit 1
    fi
fi

VENV_DIR="$PROJECT_ROOT/.venv"

# ---------------------------------------------------------------------
# Creation: Create the virtual environment if it does not already exist.
# ---------------------------------------------------------------------
if [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# ---------------------------------------------------------------------
# Activation: Activate the virtual environment in the current shell.
# ---------------------------------------------------------------------
# shellcheck disable=SC1091
. "$VENV_DIR/bin/activate"

# ---------------------------------------------------------------------
# Configuration: Point pip to the Tsinghua mirror for faster downloads
# within China.
# ---------------------------------------------------------------------
cat > "$VENV_DIR/pip.conf" << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF

# ---------------------------------------------------------------------
# Dependency Installation: Install all project requirements.
# ---------------------------------------------------------------------
pip install -r "$PROJECT_ROOT/requirements.txt"

# ---------------------------------------------------------------------
# Cleanup & Feedback: provide confirmation.
# ---------------------------------------------------------------------
echo "Virtual environment setup completed."
echo "Venv is located at: $VENV_DIR"
