---
description: Initialize the project to prepare for subsequent development.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Initialize Environment**
   - Ensure the development environment supports the following tools and languages: `nodejs`, `python`.
   - Ensure the IDE installs recommended extensions and plugins based on the project configuration files (`.vscode/extensions.json`).
     - **Dynamic IDE Detection**: First, intelligently detect which AI IDE the user is currently running (e.g., `code` for VSCode/Antigravity, `cursor` for Cursor AI, `windsurf` for Windsurf, `trae` for Trae, etc.).
     - Execute the appropriate CLI command to parse the JSON and install the extensions automatically matching the current IDE binary.
       - _Example for VS Code/Antigravity_: `cat .vscode/extensions.json | grep -Eo '"[a-zA-Z0-9.-]+"' | tr -d '"' | xargs -L 1 code --install-extension --force`
       - _Example for Cursor_: `cat .vscode/extensions.json | grep -Eo '"[a-zA-Z0-9.-]+"' | tr -d '"' | xargs -L 1 cursor --install-extension --force`
