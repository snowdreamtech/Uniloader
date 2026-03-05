<!--
SYNC IMPACT REPORT
- Version change: 0.0.0 → 1.0.0
- Modified principles:
  - [PRINCIPLE_1_NAME] → I. Modular Four-Layer Architecture
  - [PRINCIPLE_2_NAME] → II. Unified Cross-Platform Deployment
  - [PRINCIPLE_3_NAME] → III. Absolute Idempotence
  - [PRINCIPLE_4_NAME] → IV. 100% FQCN Compliance
  - [PRINCIPLE_5_NAME] → V. Environment-Aware Dynamic Behavior
- Added sections: Architecture Constraints (Section 2), Development & Testing Workflow (Section 3)
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md (Updated Constitution Check section)
  - ✅ .specify/templates/tasks-template.md (Added idempotency block in tasks)
- Follow-up TODOs: None
-->

# Unified Loader System (ULS) Constitution

## Core Principles

### I. Modular Four-Layer Architecture

The system MUST strictly adhere to the four-layer design: Base layer (`facts_loader`/`os_loader`) for OS detection and permission abstraction, Implementation layer (`container`/`native` roles) encapsulating runtimes, Application API layer (`app` roles) providing unified deployment interfaces masking underlying differences, and Orchestration layer (`playbooks`) combining scenarios like bootstrap, foundation, and orchestrator.

### II. Unified Cross-Platform Deployment

The codebase MUST remain a single source of truth compatible across Alpine, Debian, and RHEL. Container runtime support (`container_loader`) MUST uniformly cover Docker, Podman, Containerd, and CRI-O without platform-specific fragmentation in the App API layer.

### III. Absolute Idempotence

All tasks, especially `ansible.builtin.shell` and `ansible.builtin.command`, MUST explicitly define `changed_when` (and optionally `failed_when`) conditions. The system MUST safely run multiple times without unintended side effects or redundant operations.

### IV. 100% FQCN Compliance

Complete Fully Qualified Collection Name (FQCN) compliance is mandatory. All modules, roles, and plugins MUST use their full namespace (e.g., `ansible.builtin.shell` instead of `shell`) to ensure deterministic behavior, avoid collection path conflicts, and maintain strict standardization.

### V. Environment-Aware Dynamic Behavior

Deployments MUST leverage the `node_tags` mechanism (including tags like `host`, `container`, `dev`, `prod`, `open`, `restricted`) to dynamically adapt configurations, package loading behaviors (via `package_loader`), and runtime states without hardcoding environment-specific logic.

## Architecture Constraints

The project relies on a highly capable internal routing system. The `package_loader` MUST maintain and route between 38+ installation methods, including mainstream OS package managers (apk/apt/dnf), language/ecosystem managers (pip/npm/cargo/go/gem), and platform-specific formats (mas:/winget:/choco:). Roles MUST be structurally organized into the explicit 14 categories (such as `base`, `bootstrap`, `container`, `native`, `apps`, `scenarios`, `init`, `security`).

## Development & Testing Workflow

All code changes MUST successfully pass the local Docker Compose testing environment before submission. Development should accommodate the extensive catalog of ~81 mainstream software applications supported in the `apps` category, ensuring seamless deployment pathways (bootstrap, deploy, develop, server, desktop).

## Governance

This Constitution supersedes all other feature documentation. Amendments to these principles require explicit documentation, approval updates, and an impact verification on the four-layer architecture. All pull requests, code reviews, and generation pipelines MUST verify compliance with absolute idempotence (`changed_when`) and full FQCN standardization.

**Version**: 1.0.0 | **Ratified**: 2026-02-26 | **Last Amended**: 2026-02-26
