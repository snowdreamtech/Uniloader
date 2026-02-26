# Feature Specification: Unified Loader System (ULS) Framework

**Feature Branch**: `002-uls-framework`
**Created**: 2026-02-26
**Status**: Draft
**Input**: User description: "这是一个名为 '统一加载器系统（Unified Loader System）' 的企业级 Ansible 自动化框架，其核心特点是通过模块化 Loader 架构实现跨平台统一部署..."

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Cross-Platform OS & Permission Abstraction (Priority: P1)

As a DevOps Engineer, I want the system to seamlessly abstract OS detection and permissions across Alpine, Debian, and RHEL using a unified base layer (`facts_loader` and `os_loader`), so I can execute playbooks interchangeably without needing conditional OS checks.

**Why this priority**: Hardware, OS, and permission mapping is the foundational bedrock required for all subsequent automation tasks.

**Independent Test**: Can be independently tested by running a baseline OS detection playbook across clean Alpine, Debian, and RHEL instances to verify it correctly extracts unified host facts.

**Acceptance Scenarios**:

1. **Given** a raw Alpine Linux container/VM, **When** invoking the `os_loader`, **Then** the system registers accurate generalized OS variables mapping `apk` as the primary subsystem.
2. **Given** a RHEL system with restrictive permissions, **When** the base loader executes, **Then** it accurately encapsulates the permission escalation requirements transparently.

---

### User Story 2 - Unified Package Management via `package_loader` (Priority: P1)

As a systems administrator, I want to use a unified `package_loader` interface capable of routing over 38+ installation methods natively (including OS managers like apt/dnf, language ecosystems like pip/npm/cargo, and specialized tools like winget/choco/mas) to avoid maintaining fractured, tool-specific scripts.

**Why this priority**: Package installation is the primary state change operation for most infrastructure pipelines. A single unified entrypoint significantly minimizes configuration syntax drift.

**Independent Test**: Tested by parsing a YAML definition requesting packages from APT, NPM, and Cargo simultaneously, validating identical loader syntax routes them successfully to their respective handlers.

**Acceptance Scenarios**:

1. **Given** a mixed dependency requirement (e.g., Node.js and a Python pip library), **When** applying the `package_loader` module, **Then** both dependencies install synchronously using the same generic interface list.

---

### User Story 3 - Multi-Runtime Container Deployment (Priority: P2)

As an infrastructure operator, I need `container_loader` to standardize deployments targeting Docker, Podman, Containerd, or CRI-O environments through a unified API, ensuring my application layer (`apps`) remains oblivious to the underlying containerizer runtime.

**Why this priority**: Avoids vendor lock-in and allows seamless transitioning from Docker to Podman or Containerd in security-conscious or restricted production systems.

**Independent Test**: Can be tested by invoking an application role deployment sequence configured for Docker, then rerunning the exact same deployment configuration toggled to target Podman, validating identical functional containers.

**Acceptance Scenarios**:

1. **Given** a containerized application deployment, **When** the `container_loader` executes under a Podman configuration, **Then** the application spins up identically to its Docker counterpart without app-layer playbook changes.

---

### User Story 4 - Environment-Aware Dynamic Behavior (Priority: P2)

As a Site Reliability Engineer, I want the system to natively leverage runtime `node_tags` (e.g., `host`, `container`, `dev`, `prod`, `open`, `restricted`) so that deployments dynamically adjust their constraints, resource allocations, and feature subsets without maintaining separate code branches.

**Why this priority**: Contextual awareness allows the exact same playbook to safely apply local developer testing stacks differently than highly secured production bare-metal servers.

**Independent Test**: Can be fully tested by applying identical playbooks to a node tagged `dev` and a node tagged `prod`, verifying restricted policies trigger gracefully exclusively in production.

**Acceptance Scenarios**:

1. **Given** a node tagged `restricted` and `prod`, **When** the orchestrator runs, **Then** it bypasses aggressive caching optimizations and enforces strict security initialization modules.

---

### Edge Cases

- What happens when a targeted package manager within the 38+ supported isn't installed natively on the system during execution?
- How does the system handle concurrent runtime conflicts if `container_loader` detects both Docker and Podman running?
- How are permission elevation (sudo) errors categorized when running on isolated environment tags (`container`, `restricted`)?

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: System MUST strictly adhere to a four-layer architecture: Base (`facts_loader`/`os_loader`), Implementation (`container`/`native`), Application API (`apps`), and Orchestration (`playbooks`/`scenarios`).
- **FR-002**: System MUST structure roles within 14 categorized directories (e.g., base, bootstrap, container, native, apps, scenarios, init, security) cleanly partitioning logic.
- **FR-003**: System MUST execute 100% idempotently; all `ansible.builtin.shell` or related commands MUST define explicitly tracked `changed_when` directives.
- **FR-004**: System MUST maintain 100% Fully Qualified Collection Name (FQCN) compliance without utilizing short module names for deterministic behavior.
- **FR-005**: System MUST provide deployment workflows spanning across physical hosts, containers, and specialized nodes transparently utilizing the unified API interface.

### Key Entities

- **Four-Layer Map**: Abstract representation defining boundaries (Base -> Implementation -> App API -> Orchestration).
- **package_loader**: Primary routing entity determining methodology for 38+ manager interfaces.
- **node_tags**: Meta-configuration mapping containing environments constraints (`dev`/`prod`/`container`).

### Assumptions & Dependencies

- **Assumption**: The target node supports standard SSH connectivity and has a bootstrap mechanism to execute primitive Python code.
- **Dependency**: The control node must have Ansible installed with required community extensions for specialized package managers.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: **Unified Pipeline Success**: 100% test sequence passing for application deployments simultaneously tested against Alpine, Debian, and RHEL nodes via CI/CD.
- **SC-002**: **Absolute Idempotency**: Secondary execution traversals of the playbooks register exactly `0 changed` tasks, validating idempotency.
- **SC-003**: **FQCN Validation**: Linter verifies exactly 0 violations of strict FQCN usage across all 69 modules and playbooks.
- **SC-004**: **App Deployment Reliability**: Deploying a complex software instance (from the 81 total applications) via the `apps` layer operates flawlessly regardless of backing it via `native` or `container` runtimes.
