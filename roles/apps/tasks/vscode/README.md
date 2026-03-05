# Visual Studio Code

Visual Studio Code (VS Code) app role for cross-platform deployment.

## Design & Architecture

### Overview

This role provides a unified interface for installing Visual Studio Code on Windows, macOS, and Linux (Debian/RHEL). It handles architecture-specific logic (x64 vs ARM) and prioritizes native package repositories.

### Architecture

```text
[app role] -> [vscode/native/default.yml]
                  |
                  +-> [debian.yml] (Apt/Repo)
                  +-> [redhat.yml] (Yum/Repo)
                  +-> [darwin.yml] (Brew Cask)
                  +-> [windows.yml] (Winget)
                  +-> [extensions.yml] (Extension install)
```

### Design Principles

1. **Auditable**: Fully logged via `log_loader`.
2. **Overridable**: Use `vscode_extensions` to customize installation.
3. **Extensible**: New platforms can be added in `native/`.
4. **Lean**: No configuration injection unless the package is successfully installed.

## Usage Guide

### Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `vscode_extensions` | List of extensions to install | `[]` |
| `vscode_channel` | Installation channel (stable/insiders) | `stable` |

### Usage Examples

#### Simple Installation

```yaml
- ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "vscode"
```

#### Advanced Installation (with extensions)

```yaml
- ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "vscode"
    vscode_extensions:
      - "ms-python.python"
      - "golang.go"
      - "eamodio.gitlens"
```

## Operations Guide

### Pre-Deployment Checklist

- Ensure `context` role has run to populate `os_fingerprint` and `ansible_architecture`.
- For Linux, ensure connectivity to `packages.microsoft.com`.

### Troubleshooting

- **Architecture Mismatch**: Ensure `ansible_architecture` is correctly gathered.
- **Extension Install fails**: Verify VS Code is installed and `code` is in `PATH`.

## Security Considerations

- Uses official Microsoft repositories signed by GPG keys.
- Extensions are installed in user context.

## Development Guide

New installation methods or platform-specific logic should be placed in `roles/apps/tasks/vscode/native/`.
