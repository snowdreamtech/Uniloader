# Ansible Project-Specific Conventions

> This file defines conventions specific to **this** Ansible repository.
> For universal Ansible best practices, refer to the shared `ansible.md` in the template rule set.

## 1. Loader System Architecture

This project follows a **Unified Loader System** governed by four pillars:

- **Auditable**: Every significant routing/loader decision MUST record its rationale in an audit trail fact (e.g., `orchestrator_audit_trail`) and emit structured logs via `log_loader`.
- **Overridable**: Roles MUST use the variable hierarchy (`defaults` → `vars` → `group_vars` → `host_vars`) with role-namespaced control variables (e.g., `orchestrator_manual_mode`).
- **Extensible**: Logic MUST be decoupled into atomic task files. Use lookup tables (e.g., `scenario_map`) and metadata dictionaries (e.g., `scenario_definitions`) rather than hardcoded conditionals.
- **Lean**: Follow the "detect tool presence before applying configuration" principle. Do NOT create config files or inject env vars if the corresponding tool is not installed.

### Loader Resolution Order

**Variable Loading (additive, low → high priority)**:

```
default.yml → app_name.yml → mode.yml → family.yml / distro.yml → mode/family.yml / mode/distro.yml
```

**Task Resolution (best match, specific → generic)**:

```
mode/distro-version → mode/distro → mode/app_name → app_name → mode → distro → default
```

### Core Component Roles

| Component        | Role / Path                                  | Responsibility                                        |
| ---------------- | -------------------------------------------- | ----------------------------------------------------- |
| Facts            | `roles/context/tasks/facts_*.yml`            | Normalize raw `ansible_*` facts into `os_*` variables |
| Privileges       | `roles/native/tasks/privilege_loader.yml`    | Manage privilege escalation per task                  |
| App Loader       | `roles/native/tasks/app_loader.yml`          | Unified software deployment entry point               |
| Package Loader   | `roles/native/tasks/package_loader/main.yml` | 38+ installation method dispatcher                    |
| Container Loader | `roles/container/tasks/container_loader.yml` | Container engine detection and dispatch               |
| Orchestrator     | `roles/orchestrator/`                        | Scenario composition and dependency management        |
| Log Loader       | `roles/*/tasks/log_loader.yml`               | Structured, labeled audit log output                  |

## 2. Normalized Fact Variables

MUST use normalized `os_*` variables from `roles/context/` instead of raw `ansible_*` facts:

| Raw Ansible Fact                     | Normalized Variable             | Defined In     |
| ------------------------------------ | ------------------------------- | -------------- |
| `ansible_pkg_mgr`                    | `os_pkg_mgr`                    | `facts_os.yml` |
| `ansible_os_family`                  | `os_family`                     | `facts_os.yml` |
| `ansible_distribution`               | `os_distribution`               | `facts_os.yml` |
| `ansible_distribution_major_version` | `os_distribution_major_version` | `facts_os.yml` |
| `ansible_processor_vcpus`            | `os_vcpus`                      | `facts_os.yml` |
| `ansible_user_dir`                   | `os_user_home`                  | `facts_os.yml` |

- If a normalized variable does not exist, MUST define it in the appropriate `roles/context/tasks/facts_*.yml` before using it.
- The `os_fingerprint` fact MUST be appended to every task `name:` that has one.
- The `os_paths` variable MUST be prepended to `PATH` in all `shell`/`command` tasks to ensure tool detection in non-interactive shells.

## 3. Role Naming & Variable Namespacing

- All role control variables MUST be namespaced with the role name:
  - ✅ `native_install_cmd`, `orchestrator_manual_mode`, `app_service_enabled`
  - ❌ `install_cmd`, `manual_mode`, `service_enabled`
- Boolean activation facts follow the pattern `is_<app_name>` (e.g., `is_redis`, `is_nginx`, `is_db_node`).
- Boolean checks MUST use: `when: is_redis | default(false, true) | bool`

## 4. Collections Synchronization

The `ansible_collections` list and `requirements.yml` MUST stay in sync at all times:

- **Source of Truth**: `roles/bootstrap/vars/python/default.yml` → `ansible_collections`
- **Mirror**: `requirements.yml` → `collections` (with pinned versions)
- ANY change to `ansible_collections` MUST be immediately reflected in `requirements.yml`.
- Both files MUST be committed in the **same commit**.
- Desync causes `"couldn't resolve module/action"` failures at runtime.

## 5. App & Package Loader Conventions

### Variable Hierarchy for App Configs

App variable files live in `roles/apps/vars/<app_name>/native/` and follow strict DRY hierarchy:

```
default.yml         ← covers 90%+ systems (most important)
{family}.yml        ← family-level override (debian, redhat, darwin)
{distro}.yml        ← distro-specific (ONLY when family is insufficient)
{distro}-{ver}.yml  ← version-specific (rarely needed)
```

File creation rule: **create a more specific file ONLY when the parent level is insufficient.**

### File Header Requirement

Every distribution config file MUST begin with a documented header:

```yaml
---
# =====================================================================
# roles/apps/vars/fd/native/default.yml
#
# Purpose:
#   Default native configuration for fd.
#   Covers: Alpine, Arch, Darwin, FreeBSD, Gentoo, NetBSD,
#           OpenBSD, openSUSE (10 systems)
#
# =====================================================================

fd_overrides:
  # WHY: Most systems use 'fd' package name (no conflict with fdclone)
  app_packages: ["fd"]
```

### Software Deployment Interface

MUST use `role: app` unified interface — do NOT invoke low-level modules or native roles directly for application deployment:

```yaml
- ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "redis"
    app_service_enabled: true
```

### Logging Strategy

- MUST prioritize `log_loader` **of the current role** for structured audit output.
- Fallback to the `native` role's `log_loader` only if the current role has none.
- Exception: `bootstrap` role may use `debug` or native methods.

## 6. Scenario Design (Matrix Pattern)

Managed in `roles/scenarios/matrix/tasks/main.yml`. All supported applications are listed explicitly and conditionally activated:

```yaml
- name: "Matrix: Deploy Redis {{ '(' ~ os_fingerprint ~ ')' if os_fingerprint is defined else '' }}"
  ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "redis"
    app_service_enabled: true
  when: is_redis | default(false, true) | bool or is_db_node | default(false, true) | bool
```

**Benefit**: Every deployed application is visible at a glance; no implicit activation or hidden dependencies.

## 7. Variable Reset in Loader Files

Loader task files designed for iterative invocation (e.g., `app_loader.yml`, `native_loader.yml`, `package_loader/main.yml`, `service_loader/main.yml`, `docker_loader.yml`) MUST include an explicit variable reset block **before** normalization:

```yaml
# REQUIRED: Reset loader variables before each iteration to prevent
# set_fact values from a previous loop iteration leaking into the next.
- name: "Reset loader variables"
  ansible.builtin.set_fact:
    app_image: null
    app_packages: null
    app_homepage: null
    app_service_enabled: null
  tags: ["always"]

- name: "Normalize variables"
  ansible.builtin.set_fact:
    app_image: "{{ app_image | default(app_name, true) }}"
```

## 8. Container Volume Paths

Standard data directory locations for this project:

| Platform      | Path                                      |
| ------------- | ----------------------------------------- |
| Linux / macOS | `/opt/data/containers/volumes/{app_name}` |
| Windows       | `C:/data/containers/volumes/{app_name}`   |

- Variable files: `inventory/group_vars/all/docker_volumes.yml`
- Host overrides: `inventory/host_vars/{hostname}/`
- Dev overrides: `inventory/group_vars/dev/`
- Volume base directories MUST be created in `roles/container/tasks/container_loader.yml`, NOT in `init`.

## 9. Session Initialization Protocol

At the start of every AI session in this repository, read the following files in order:

1. `.aiconfig/ai_context.json` — project context and permanent rules
2. `.aiconfig/ai_rules.en.md` — global AI behavior rules
3. `.aiconfig/ai_ansible.en.md` — Ansible engineering standards
4. `.aiconfig/DOCUMENTATION_STANDARD.md` — documentation structure requirements
5. `.aiconfig/MARKDOWN_STYLE_GUIDE.md` — Markdown style guide

After reading, confirm understanding of:

- Four core pillars: **Auditable, Overridable, Extensible, Lean**
- Loader architecture: **Facts → Privileges → Roles → Orchestrator**
- Bilingual documentation requirements (EN + zh-CN)

## 10. Bilingual Documentation & Commit Workflow

- ALL documentation artifacts (README, Implementation Plans, Walkthroughs) MUST be generated as **two separate files**: English (`.en.md` or `README.md`) and Chinese (`_zh-CN.md` or `README_zh-CN.md`).
- Generating only one language version is **PROHIBITED**.
- Implementation plans: `implementation_plan.en.md` + `implementation_plan.zh.md`.

### Auto-Commit Trigger

When the user enters `提交代码`, `提交`, `commit`, `git commit`, or `git ci`:

1. Analyze workspace changes (`git diff`), detect submodule modifications.
2. **Submodule First**: If submodule changes exist, commit and push within each submodule BEFORE the main project.
3. Generate a full English Conventional Commits message.
4. Execute `git add`, `git commit`, and push for the main project.

## 11. Compliance & Quality Assurance

- **Audit Script Execution**: Before committing new loaders or making significant changes, you MUST run the compliance audit script: `bash .aiconfig/audit_compliance.sh`.
- **Code Review Checklist**:
  1. File header with Purpose, Simple Usage, and Comprehensive Usage
  2. All modules use FQCN (`ansible.builtin.*`, `community.*`, `containers.*`)
  3. Task names use double quotes and `os_fingerprint` suffix
  4. Conditionals use `is defined` and explicit `| bool` conversion
  5. Shell/command tasks have `changed_when` and `failed_when`
  6. Privilege escalation uses `become: "{{ become_enabled }}"`
  7. English-only comments in code files
  8. Compliance audit passes

## 12. Loader File Template & Documentation

- **Mandatory Header Template**: Every new loader task file MUST include a standardized documentation header block at the top:
  - **Purpose**: A clear description of what the loader does.
  - **Simple Usage**: Minimal parameters required for quick adoption.
  - **Comprehensive Usage**: Complete API reference with ALL available parameters and realistic values, including `become_enabled: true` if applicable.
- **Dual Examples Requirement**: Providing only one example is PROHIBITED.

## 13. Dynamic Privilege Escalation (become_enabled)

- **Variable-Driven Escalation**: ALL tasks requiring privilege escalation MUST use `become: "{{ become_enabled }}"` instead of hardcoded `become: true`.
- **Purpose**: This ensures seamless execution across different contexts (Container environments which don't need become, Root user connections, and Regular user connections).
- **Exceptions**: Only tasks within `roles/bootstrap/` are permitted to use a hardcoded `become: true` because they handle the initial raw system setup.

## 14. Prohibited Patterns (Strict)

- **Include Directives Restrictions**: NEVER use `delegate_to` or `run_once` on `include_role`, `include_tasks`, or `import_*` directives. Apply these attributes to the individual tasks _inside_ the included/imported files instead. This prevents Ansible parser errors and unpredictable variable scoping.
