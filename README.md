# Uniloader: Universal Loader System & AI IDE Framework

[![Compliance](https://img.shields.io/badge/compliance-100%25-brightgreen)](#compliance)
[![AI Supported](https://img.shields.io/badge/AI_IDEs-50%2B-blue)](#ai-interaction-guidelines)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

<p align="center">
  <img src="assets/logo/logo-512x512.png" alt="Uniloader Logo" width="250"/>
</p>

> **🤖 FOR AI ASSISTANTS**: Before working on this project, you **MUST** read [`.agent/rules/01-general.md`](.agent/rules/01-general.md) and complete the onboarding workflow (e.g., `/snowdreamtech.init`). All AI-generated code must strictly comply with the standards defined in `.agent/rules/`. Failure to do so will result in non-compliant code generation.

A production-grade, cross-distribution Ansible framework implementing the **Unified Loader System** architecture, seamlessly integrated with an **enterprise-grade AI IDE Template** supporting over 50 different AI-assisted IDEs out-of-the-box.

---

## Key Features

### 🚀 Unified Loader System (Ansible)

- **Universal Compatibility**: Single codebase for Alpine, Debian, and RHEL families, plus macOS and Windows support.
- **Dual Delivery Modes**: Seamless switching between native packages and containers.
- **Loader Architecture**: Modular, reusable components with standardized interfaces.
- **Enterprise-Grade**: Full audit logging, idempotency, and safety guarantees.
- **Self-Documenting**: Every loader includes Simple + Comprehensive usage examples.

### 🤖 AI IDE Collaboration

- **Multi-IDE Compatibility**: Native support for Cursor, Windsurf, GitHub Copilot, Cline, Roo Code, Trae, Gemini, and dozens of other AI editors.
- **Unified Rule System**: Centralized rule definitions in `.agent/rules/` act as the Single Source of Truth. Modifying a rule here propagates to all 50+ IDEs automatically via safe symlinks.
- **Intelligent Workflows**: Standardized `.agent/workflows/` (commands) such as `speckit.plan`, `speckit.analyze`, and `snowdreamtech.init`.
- **Secure & Compliant**: Built-in architecture guardrails, strict credential management, and isolated `.gitignore` boundaries.

---

## Table of Contents

- [Directory Structure](#directory-structure)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Node Tags](#node-tags)
- [Development & AI Integration](#development--ai-integration)
- [Best Practices](#best-practices)
- [Compliance](#compliance)
- [Contributing](#contributing)

---

## 📂 Directory Structure

```text
project-root/
├── .agent/              # 🤖 Canonical AI configuration (The Brain)
│   ├── rules/           # 📏 Unified AI behavioral rules (80+ sets, SSoT)
│   └── workflows/       # 🛠️ Unified commands & AI workflows (SpecKit)
├── .agents/             # 🧩 Shared command sources (Auto-managed symlinks)
├── .gemini/             # ♊ Gemini-specific extensions and CLI configs
├── .github/             # 🐙 GitHub integration & Copilot settings
├── .cline/              # 🔗 Example of IDE-specific redirect folder (50+ included)
├── assets/              # 🎨 Project assets and logos
├── inventory/           # � Per-environment inventory files
├── roles/               # 🧩 Reusable Ansible roles
└── playbooks/           # � Top-level orchestration playbooks
```

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
  -e "@~/.vault.yml" --vault-password-file ~/.vault_pass
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
2. `{{ app_name }}.yml`: Global application metadata.
3. `{{ mode }}.yml`: Delivery mode technical baseline.
4. `{{ family/distro }}.yml`: Environmental Constraint Layer.
5. `{{ mode }}/{{ family/distro }}.yml`: Precision Override Layer.

#### 2. Best-Match Task Resolution (First Found)

Tasks are resolved using a "Specific to General" search to provide the most optimized implementation:

1. `mode/distro-version.yml`
2. `mode/distro.yml`
3. `mode/app_name.yml`
4. `app_name.yml`
5. `mode.yml`
6. `distro.yml` -> `default.yml`

### Package Loader Supported Formats

The `package_loader` supports 38+ installation methods via unified prefix syntax (e.g., `snap:`, `flatpak:`, `brew:`, `pip:`, `npm:`).

---

## Node Tags

Node tags enable dynamic behavior based on host characteristics:

- **Host Type**: `host`, `container`, `docker_host`, `podman_host`
- **Network Type**: `open`, `restricted`
- **Environment Type**: `dev`, `test`, `stage`, `prod`

---

## Development & AI Integration

### AI Interaction Guidelines

This template includes the **SpecKit** workflow suite to manage the full feature lifecycle:

| Command              | Purpose                                                        |
| :------------------- | :------------------------------------------------------------- |
| `/speckit.specify`   | Create or update feature specification from natural language.  |
| `/speckit.plan`      | Execute implementation planning and generate design artifacts. |
| `/speckit.tasks`     | Generate actionable, dependency-ordered `tasks.md`.            |
| `/speckit.implement` | Execute the implementation plan task by task.                  |
| `/speckit.analyze`   | Perform cross-artifact consistency and quality analysis.       |

## 📐 AI Interaction Guidelines

This repository strictly enforces interaction rules to prevent "AI hallucinations". By design, our IDE settings redirect the agent to read `.agent/rules/09-ai-interaction.md` upon session startup.

> **Language Notice:** While all technical code, commits, and rule definitions must be in English, all communication with the AI and user-facing documentation should default to **Simplified Chinese (简体中文)**.

**Project Rules Definition**:
If you wish to augment the AI's behavior, please **do not** modify individual IDE configuration directories directly. Instead:

1. Add or modify markdown files inside `.agent/rules/`.
2. The existing symlink topology will automatically apply your new rules to all 50+ AI environments.

### Local Testing Environment

```bash
# Start development containers
docker compose -f docker/docker-compose.yml up -d

# Run playbooks against local containers
ansible-playbook -i inventory/dev.yml playbooks/base/init.yml
```

### Debugging

```bash
ansible-playbook -v   # Basic task output
ansible-playbook -vvv # Connection debugging
ansible-playbook -i inventory/dev.yml playbooks/base/init.yml --check # Dry run
```

---

## Best Practices

### 1. Follow the Project-Specific Rules

Review `.agent/rules/ansible.md` and `.agent/rules/ansible-local.md` for strict guidelines on:

- Idempotency and Zero-Tolerance Linting
- Variable resets in task loops
- Matrix scenario deployment patterns

### 2. Follow the Loader Template

Every new loader MUST include a file header with **Purpose**, **Simple Usage**, and **Comprehensive Usage**.

### 3. Use FQCN for All Modules

✅ **Correct:** `ansible.builtin.debug`
❌ **Wrong:** `debug`

### 4. Privilege Escalation

All tasks requiring privilege escalation MUST use `become: "{{ become_enabled }}"` instead of hardcoded `become: true`.

---

## Compliance

This project is deeply integrated with the `.agent/rules/` specification:

- **FQCN Usage**: 100% Fully Qualified Collection Names.
- **Task Naming**: Double quotes + `os_fingerprint` suffix required.
- **Attribute Safety**: No `delegate_to` run_once on `include_role`.
- **Idempotency**: All `shell` and `command` tasks define `changed_when`.

---

## Contributing

### For Human Developers

1. Read `.agent/rules/01-general.md` and `.agent/rules/02-coding-style.md`.
2. Review `.agent/rules/ansible.md` for Ansible-specific requirements.
3. Ensure all new loaders have Simple + Comprehensive usage examples.

### For AI Assistants

This project is **AI-optimized**. All AI-generated code MUST comply with the standards in `.agent/rules/`.

## License

This project is licensed under the **MIT License**.
Copyright (c) 2026-present [SnowdreamTech Inc.](https://github.com/snowdreamtech)

---

**Status**: ✅ Production-Ready | 🎯 AI-Optimized Reference Implementation
