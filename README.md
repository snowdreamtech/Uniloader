<div align="center">
  <img src="assets/logo/logo-512x512.png" alt="Uniloader Logo" width="200"/>
</div>

# Unified Loader System - Enterprise Ansible Framework

[![GitHub Actions Lint](https://github.com/snowdreamtech/Uniloader/actions/workflows/lint.yml/badge.svg)](https://github.com/snowdreamtech/Uniloader/actions/workflows/lint.yml)
[![GitHub Actions CI](https://github.com/snowdreamtech/Uniloader/actions/workflows/ci.yml/badge.svg)](https://github.com/snowdreamtech/Uniloader/actions/workflows/ci.yml)
[![GitHub Actions CD](https://github.com/snowdreamtech/Uniloader/actions/workflows/cd.yml/badge.svg)](https://github.com/snowdreamtech/Uniloader/actions/workflows/cd.yml)
[![GitHub Release](https://img.shields.io/github/v/release/snowdreamtech/Uniloader?include_prereleases&sort=semver)](https://github.com/snowdreamtech/Uniloader/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CodeSize](https://img.shields.io/github/languages/code-size/snowdreamtech/Uniloader)](https://github.com/snowdreamtech/Uniloader)
[![Dependabot Enabled](https://img.shields.io/badge/Dependabot-Enabled-brightgreen?logo=dependabot)](https://github.com/snowdreamtech/Uniloader/blob/main/.github/dependabot.yml)

A production-grade, cross-distribution Ansible framework implementing the **Unified Loader System** architecture. Supports Alpine, Debian/Ubuntu, and RHEL/CentOS with consistent APIs across native packages and container runtimes.

---

## Key Features

- **Universal Compatibility**: Single codebase for Alpine, Debian, and RHEL families
- **Dual Delivery Modes**: Seamless switching between native packages and containers
- **Loader Architecture**: Modular, reusable components with standardized interfaces
- **Enterprise-Grade**: Full audit logging, idempotency, and safety guarantees
- **Self-Documenting**: Every loader includes Simple + Comprehensive usage examples

---

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Node Tags](#node-tags)
- **Development**: [Development](#development)
- **Best Practices**: [Best Practices](#best-practices)
- **Contributing**: [Contributing](#contributing)

---

## Quick Start

### Prerequisites

```bash
# Install Ansible and required collections
pip install ansible
ansible-galaxy collection install -r requirements.yml
```

### Basic Usage

```bash
# Initialize new servers
ansible-playbook -i inventory/dev.yml playbooks/base/init.yml

# With vault for sensitive data
ansible-playbook -i inventory/prod.yml playbooks/base/init.yml \
  -e "@~/.uniloader/.vault.yml" --vault-password-file ~/.uniloader/.vault_pass
```

### Deploy an Application

```yaml
# Container mode
- ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "nginx"
    app_delivery_mode: "container"
    app_image: "nginx:alpine"
    app_ports: ["80:80"]

# Native mode
- ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "nginx"
    app_delivery_mode: "native"
    app_packages: ["nginx"]
    app_state: "started"
```

---

## Architecture

### The Loader System

The project implements a **four-layer architecture**:

```text
┌─────────────────────────────────────────────────────────┐
│ Layer 4: Orchestration (Playbooks)                     │
│ - Scenario composition                                  │
│ - Multi-role coordination                               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Layer 3: Application API (app role)                    │
│ - Unified deployment interface                          │
│ - Mode selection (container vs native)                  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Layer 2: Implementation (container, native roles)      │
│ - Container: Docker, Podman, Containerd, CRI-O         │
│ - Native: Package, Service, File loaders               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Layer 1: Foundation (facts_loader, os_loader)          │
│ - OS detection and normalization                        │
│ - Privilege management (become_enabled)                 │
│ - Cross-distribution abstraction                        │
└─────────────────────────────────────────────────────────┘
```

### Loader Design Patterns

The system employs a deterministic resolution logic for both variables and tasks:

#### 1. Additive Variable Hierarchy (Last Wins)

Variables are merged following a "General to Specific" funnel to ensure environmental constraints override technical defaults:

1. `default.yml`: Absolute base defaults.
2. `{{ app_name }}.yml`: Global application metadata (version, origin).
3. `{{ mode }}.yml`: Delivery mode technical baseline (e.g., native/container defaults).
4. `{{ distro }}.yml`: **Environmental Constraint Layer** (e.g., Alpine-specific package names).
5. `{{ mode }}/default.yml`: Mode-specific technical baseline.
6. `{{ mode }}/{{ distro }}.yml`: **Precision Override Layer** (e.g., specific native config for Alpine).

#### 2. Best-Match Task Resolution (First Found)

Tasks are resolved using a "Specific to General" search to provide the most optimized implementation:

1. `mode/distro-version.yml`: Precision specialized implementation.
2. `mode/distro.yml`: OS-specific implementation for the delivery mode.
3. `mode/app_name.yml`: Application-specific logic within a delivery mode.
4. `app_name.yml`: Universal application logic.
5. `mode/default.yml` -> `mode.yml`: Fallback to generic delivery mode logic.
6. `distro.yml` -> `default.yml`: Final fallback to generic OS/base tasks.

### Core Loaders

| Loader                  | Purpose                        | Example                                    |
| :---------------------- | :----------------------------- | :----------------------------------------- |
| `facts_loader`          | OS detection, fingerprinting   | Auto-detects Alpine/Debian/RHEL            |
| `os_loader`             | Distribution-specific dispatch | Routes to alpine.yml/debian.yml/redhat.yml |
| `package_loader`        | Universal package management   | Works with apk/apt/dnf                     |
| `service_loader`        | Service lifecycle control      | Handles systemd/openrc/sysvinit            |
| `container_loader`      | Container orchestration        | Supports Docker/Podman/Containerd          |
| `docker_compose_loader` | Multi-container apps           | Docker Compose V2 integration              |

### Package Loader Supported Formats

The `package_loader` supports **38+ installation methods** via unified prefix syntax:

| Category                    | Prefix      | Examples                                                                 |
| :-------------------------- | :---------- | :----------------------------------------------------------------------- |
| **System Package Managers** | _(none)_    | `nginx`, `curl`, `vim`                                                   |
| **Local Files**             | _(path)_    | `/tmp/app.deb`, `/tmp/app.rpm`, `/tmp/app.apk`                           |
| **Remote URLs**             | _(https)_   | `https://example.com/app.deb`                                            |
| **macOS Formats**           | _(path)_    | `.dmg`, `.pkg`, `.mpkg`, `.app`, `.zip`, `.framework`, `.dylib`, `.kext` |
| **Mac App Store**           | `mas:`      | `mas:497799835`, `mas:Xcode`                                             |
| **Windows Winget**          | `winget:`   | `winget:Microsoft.VisualStudioCode`                                      |
| **Chocolatey**              | `choco:`    | `choco:7zip`, `choco:nodejs-lts`                                         |
| **Scoop**                   | `scoop:`    | `scoop:neovim`, `scoop:fzf`                                              |
| **MS Store**                | `msstore:`  | `msstore:9NBLGGH5R558`                                                   |
| **Snap**                    | `snap:`     | `snap:code`, `snap:spotify`                                              |
| **Flatpak**                 | `flatpak:`  | `flatpak:org.gimp.GIMP`                                                  |
| **Nix**                     | `nix:`      | `nix:ripgrep`, `nix:fd`                                                  |
| **GNU Guix**                | `guix:`     | `guix:emacs`                                                             |
| **AUR**                     | `aur:`      | `aur:google-chrome`                                                      |
| **Python pip**              | `pip:`      | `pip:ansible-lint`, `pip:requests==2.28.0`                               |
| **Python pipx**             | `pipx:`     | `pipx:black`, `pipx:poetry`                                              |
| **Conda**                   | `conda:`    | `conda:numpy`, `conda:pandas`                                            |
| **npm**                     | `npm:`      | `npm:typescript`, `npm:eslint`                                           |
| **Yarn**                    | `yarn:`     | `yarn:prettier`                                                          |
| **pnpm**                    | `pnpm:`     | `pnpm:vite`                                                              |
| **Bun**                     | `bun:`      | `bun:elysia`                                                             |
| **Deno**                    | `deno:`     | `deno:fresh`                                                             |
| **Cargo**                   | `cargo:`    | `cargo:ripgrep`, `cargo:bat`                                             |
| **Go**                      | `go:`       | `go:github.com/junegunn/fzf@latest`                                      |
| **Ruby gem**                | `gem:`      | `gem:rails`, `gem:bundler`                                               |
| **Composer**                | `composer:` | `composer:laravel/installer`                                             |
| **Dart**                    | `dart:`     | `dart:stagehand`                                                         |
| **Nim**                     | `nim:`      | `nim:choosenim`                                                          |
| **.NET**                    | `dotnet:`   | `dotnet:dotnet-ef`                                                       |
| **Coursier**                | `cs:`       | `cs:scalafmt`                                                            |
| **SDKMAN**                  | `sdk:`      | `sdk:java`, `sdk:gradle`                                                 |

## See [roles/native/tasks/package_loader/main.yml](roles/native/tasks/package_loader/main.yml) for complete API reference

## Node Tags

Node tags enable dynamic behavior based on host characteristics:

### Host Type

- `host` - Physical or virtual machine
- `container` - Container environment
- `docker_host` - Docker daemon host
- `podman_host` - Podman runtime host
- `docker_container` - Running inside Docker
- `podman_container` - Running inside Podman

### Network Type

- `open` - Unrestricted internet access
- `restricted` - Behind firewall/proxy (uses mirrors)

### Environment Type

- `dev` - Development environment
- `test` - Testing environment
- `stage` - Staging environment
- `prod` - Production environment

### Example Inventory

```yaml
all:
  hosts:
    dev-web:
      node_tags: ["host", "docker_host", "dev", "open"]
    prod-db:
      node_tags: ["host", "podman_host", "prod", "restricted"]
    test-container:
      node_tags: ["container", "docker_container", "test"]
```

---

## Development

### Local Testing Environment

```bash

# Start development containers

docker compose -f docker/docker-compose.yml up -d

# Access test environments

docker exec -it alpine /bin/sh
docker exec -it debian /bin/bash
docker exec -it redhat /bin/bash

# Run playbooks against local containers

ansible-playbook -i inventory/dev.yml playbooks/base/init.yml
```

### Debugging

```bash

# Verbose output levels

ansible-playbook -v   # Basic task output
ansible-playbook -vv  # Task input/output
ansible-playbook -vvv # Connection debugging
ansible-playbook -vvvv # Full SSH debugging

# Limit to specific hosts

ansible-playbook -i inventory/dev.yml playbooks/base/init.yml --limit alpine

# Check mode (dry run)

ansible-playbook -i inventory/dev.yml playbooks/base/init.yml --check
```

---

## Best Practices

### 1. Follow the Loader Template

Every new loader MUST include:

```yaml
# =====================================================================
# roles/[role]/tasks/[loader_name].yml
#
# Purpose:
#   [Clear description of what this loader does]
#
# Simple Usage:
#   - ansible.builtin.include_role:
#       name: "[role]"
#       tasks_from: "[loader_name]"
#     vars:
#       [minimal_required_param]: "value"
#
# Comprehensive Usage:
#   - ansible.builtin.include_role:
#       name: "[role]"
#       tasks_from: "[loader_name]"
#     vars:
#       [param1]: "value1"
#       [param2]: "value2"
#       # ... ALL available parameters with realistic values
#       become_enabled: true
#
# =====================================================================
```

### 3. Maintain Dual Examples

- **Simple Usage**: Minimal parameters for quick adoption
- **Comprehensive Usage**: Complete API reference with ALL parameters

**Example**: See [roles/container/tasks/docker_compose_loader.yml](roles/container/tasks/docker_compose_loader.yml)

### 4. Use FQCN for All Modules

❌ **Wrong:**

```yaml
- debug:
    msg: "Hello"
```

✅ **Correct:**

```yaml
- ansible.builtin.debug:
    msg: "Hello"
```

### 5. Task Naming Convention

All tasks with names MUST:

- Use double quotes
- Append `os_fingerprint` suffix

```yaml
- name: "Install packages {{ '(' ~ os_fingerprint ~ ')' if os_fingerprint is defined else '' }}"
  ansible.builtin.package:
    name: "{{ packages }}"
```

**Exception**: `assert`, `include_role`, `include_tasks`, `import_*` MUST NOT have names.

### 6. Safe Conditional Logic

❌ **Wrong:**

```yaml
when: my_var
when: my_var == true
```

✅ **Correct:**

```yaml
when: my_var is defined and my_var | bool
when: my_var | default(false, true) | bool
```

### 7. Idempotency Markers

All `shell` and `command` tasks MUST define:

```yaml
- name: "Execute script {{ '(' ~ os_fingerprint ~ ')' if os_fingerprint is defined else '' }}"
  ansible.builtin.shell: |
    set -eu
    ./my-script.sh
  changed_when: "'Updated' in script_result.stdout"
  failed_when: script_result.rc != 0
  register: script_result
```

### 8. Privilege Escalation

Use the standardized `become_enabled` variable:

```yaml
- name: "Install system package {{ '(' ~ os_fingerprint ~ ')' if os_fingerprint is defined else '' }}"
  ansible.builtin.package:
    name: "nginx"
    state: "present"
  become: "{{ become_enabled }}"
```

This automatically handles:

- Container environments (no become needed)
- Root user connections (no become needed)
- Regular user connections (become enabled)

**Important**: All tasks requiring privilege escalation MUST use `become: "{{ become_enabled }}"` instead of hardcoded `become: true`, except for tasks in `roles/bootstrap/` where `become: true` is required for initial system setup.

### 9. Prohibited Patterns

❌ **Never use `delegate_to` or `run_once` on include directives:**

```yaml
# WRONG - Will cause parser errors

- name: "Load configuration"
  ansible.builtin.include_role:
    name: "native"
    tasks_from: "log_loader"
  delegate_to: "localhost" # ❌ Not allowed
  run_once: true # ❌ Not allowed
```

✅ **Correct - Apply attributes to tasks inside the loader:**

```yaml
# Inside log_loader.yml

- name: "Output log message"
  ansible.builtin.debug:
    msg: "{{ log_message }}"
  delegate_to: "localhost" # ✅ Correct
```

### 10. Reference Existing Loaders

When creating new loaders, use these as templates:

- **Container orchestration**: [roles/container/tasks/docker_compose_loader.yml](roles/container/tasks/docker_compose_loader.yml)
- **Package management**: [roles/native/tasks/package_loader/main.yml](roles/native/tasks/package_loader/main.yml)
- **Service control**: [roles/native/tasks/service_loader/main.yml](roles/native/tasks/service_loader/main.yml)
- **File operations**: [roles/native/tasks/file_loader.yml](roles/native/tasks/file_loader.yml)

---

---

## Contributing

### For Human Developers

1. Read [ansible.md](.agent/rules/ansible.md) and [ansible-local.md](.agent/rules/ansible-local.md)
2. Ensure all new loaders have Simple + Comprehensive usage examples

### Code Review Checklist

- [ ] File header with Purpose, Simple Usage, and Comprehensive Usage
- [ ] All modules use FQCN (ansible.builtin._, community._, containers.\*)
- [ ] Task names use double quotes and os_fingerprint suffix
- [ ] No `delegate_to`/`run_once` on `include_role`/`include_tasks`
- [ ] Conditionals use `is defined` and explicit `| bool` conversion
- [ ] Shell/command tasks have `changed_when` and `failed_when`
- [ ] Privilege escalation uses `become: "{{ become_enabled }}"`
- [ ] English-only comments in code files

---

## Additional Resources

- **Standards**: [.agent/rules/ansible.md](.agent/rules/ansible.md) | [.agent/rules/ansible-local.md](.agent/rules/ansible-local.md)
- **Examples**: [roles/](roles/) - Every loader is self-documenting

---

## License

MIT License - See [LICENSE](LICENSE) for details

---

## Acknowledgments

This framework implements enterprise-grade Ansible patterns refined through production deployments across Alpine, Debian, and RHEL ecosystems. The Unified Loader System architecture enables consistent, maintainable infrastructure automation at scale.

**Status**: ✅ Production-Ready | 🎯 Reference Implementation
