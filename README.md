# Unified Loader System (ULS) Framework

An enterprise Ansible automation framework designed for Absolute Idempotency and Cross-Platform deployment transparency.

## Architecture

The ULS Framework achieves single-codebase stability across environments (Alpine, Debian, RHEL, Docker, Podman) using a **Modular Four-Layer Architecture**:

1. **Base Layer** (`facts_loader`, `os_loader`): Discovers and maps the native host distributions and establishes execution privilege contexts.
2. **Implementation Layer** (`container_loader`, `package_loader`): Abstract loading mechanisms serving as routers for ecosystems like `apt`, `npm`, `cargo`, `docker`, and `podman`.
3. **App API Layer**: Specialized module declarations injecting variables into the standardized Loaders. Follows the [App API Contract](specs/001-uls-framework/contracts/app_api.md).
4. **Orchestration Layer** (`playbooks/`): Top-level scenario managers like `bootstrap.yml` providing boundary constraint validation (utilizing `node_tags`).

## Environment Awareness

Deployment behaviors automatically adjust by defining an array of strings under `node_tags` on a host.

- Constraints like `restricted`, `dev`, `test`, or `prod` dynamically alter memory capacities, persistence mounts, or container backend targetting.

## Quickstart & Verification

Please see [Quickstart & Local Verification](specs/001-uls-framework/quickstart.md) for information on provisioning the sandbox Alpine/Debian/RHEL containers via Docker Compose to validate secondary-run 0-change Idempotency rules.
