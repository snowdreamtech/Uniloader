# Research & Decisions: ULS Framework

This document outlines the best practices and internal technical decisions identified during Phase 0 for the Unified Loader System (ULS).

## 1. Node Tags Mapping (`node_tags`)

- **Decision**: `node_tags` will be evaluated as an array of tags attached to a host during the inventory or bootstrap phase.
- **Rationale**: Relying on an array of runtime tags (e.g., `['host', 'prod', 'restricted']`) allows `when` conditions across all four layers to dynamically skip or engage tasks elegantly without a complex directory of nested `group_vars`.
- **Alternatives considered**: Separate inventory files per environment (Rejected: Creates drift and breaks the "single code base" rule).

## 2. Package Loader Strategy (`package_loader`)

- **Decision**: The `package_loader` will accept a generic `packages` dictionary mapping, where the role internally dispatches the installation to specialized tasks (apt, apk, dnf, pip, etc.) based on the package prefix or type indicator.
- **Rationale**: A unified router masks the complexity and eliminates repetitive OS conditional logic in every subsequent app installation role.
- **Alternatives considered**: Standard `ansible.builtin.package` module (Rejected: Too limited; does not natively wrap Python/Node/Cargo/Go ecosystems).

## 3. Container Runtime Agnosticism (`container_loader`)

- **Decision**: The `container_loader` will abstract container execution APIs, presenting a generalized interface (e.g., `start_container`, `build_image`) that translates under the hood to `community.docker.docker_container` or `containers.podman.podman_container` dynamically.
- **Rationale**: Security environments mandate Podman exclusively in some instances, but Docker is often preferred for local dev. An abstract loader hides this transition completely.

## 4. Idempotency Enforcement

- **Decision**: All `command` and `shell` modules will pipe execution state or check file existence, using `changed_when: false` for pure read operations or `changed_when: "result.stdout text"` for active state.
- **Rationale**: Mandatory for the Constitution. Secondary runs must yield exactly zero changes.
