---
description: "Task list template for ULS Framework implementation"
---

# Tasks: Unified Loader System (ULS) Framework

**Input**: Design documents from `/specs/001-uls-framework/`
**Prerequisites**: `plan.md` (required), `spec.md` (required for user stories), `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Initialize Ansible collection/framework structure according to `plan.md`.
- [x] T002 [P] Establish local Docker Compose test environment mimicking Alpine, Debian, and RHEL per `quickstart.md`.
- [x] T003 [P] Configure `ansible-lint` to enforce 100% FQCN compliance and `changed_when` rules.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Define the meta-directories for the 14 categorized roles (`base`, `bootstrap`, `container`, `native`, `apps`, `scenarios`, `init`, `security`, etc.).
- [x] T005 Construct `playbooks/orchestrator.yml` and `playbooks/bootstrap.yml` stub files.
- [x] T006 Implement dynamic `node_tags` inventory parsing mechanisms to extract tag conditions universally.

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Cross-Platform OS & Permission Abstraction (Priority: P1) 🎯 MVP

**Goal**: System effortlessly abstracts OS detection and permissions across Alpine, Debian, and RHEL using a unified base layer (`facts_loader` and `os_loader`).
**Independent Test**: Running OS detection playbook across clean Alpine, Debian, and RHEL instances accurately extracts unified host facts (e.g. `apk` mapping).

### Implementation for User Story 1

- [x] T007 [P] [US1] Create `roles/base/facts_loader/tasks/main.yml` to normalize distribution facts statically.
- [x] T008 [P] [US1] Create `roles/base/os_loader/tasks/main.yml` to define OS boundary mapping.
- [x] T009 [US1] Implement permission escalation abstraction logic handling isolated vs non-isolated targets.
- [x] T010 [US1] Ensure all shell/command implementations within `base` roles pipe state using `changed_when: false` or regex targeting `result.stdout text`.

**Checkpoint**: User Story 1 functional. The system can successfully map underlying OS differences on Alpine, Debian, and RHEL targets.

---

## Phase 4: User Story 2 - Unified Package Management via `package_loader` (Priority: P1)

**Goal**: Unified `package_loader` interface routing 38+ installation methods (apt, dnf, pip, npm, cargo, winget, choco, mas) natively.
**Independent Test**: Parse a YAML definition natively requesting packages from APT, NPM, and Cargo and validate identical loader syntax targets them correctly.

### Implementation for User Story 2

- [x] T011 [P] [US2] Implement the `payload` dictionary parser within `package_loader` mirroring `data-model.md` definitions.
- [x] T012 [P] [US2] Create OS-level routing (apt, apk, dnf) upstream tasks within the loader.
- [x] T013 [P] [US2] Create language-ecosystem routing (pip, npm, cargo, go, gem) upstream tasks within the loader.
- [x] T014 [P] [US2] Create platform-specific routing (mas:, winget:, choco:) upstream tasks within the loader.
- [x] T015 [US2] Centralize idempotency across all package sub-routers (`changed_when` rules).

**Checkpoint**: Packages can be successfully routed to any of the 38+ interfaces transparently.

---

## Phase 5: User Story 3 - Multi-Runtime Container Deployment (Priority: P2)

**Goal**: `container_loader` standardizes deployments targeting Docker, Podman, Containerd, or CRI-O transparently to the applications layer.
**Independent Test**: Apply the exact same target app role deployment over two toggles: Docker config and Podman config. Both produce identical active containers.

### Implementation for User Story 3

- [x] T016 [P] [US3] Create the core `roles/container/container_loader/tasks/main.yml`.
- [x] T017 [US3] Implement Docker backend support leveraging FQCN `community.docker.docker_container`.
- [x] T018 [US3] Implement Podman backend support leveraging FQCN `containers.podman.podman_container`.
- [x] T019 [US3] Finalize generic abstraction inputs allowing `apps` roles to pass uniform variables mapped to either runtime.
- [x] T020 [US3] Construct baseline API compliance testing following `contracts/app_api.md`.

**Checkpoint**: Containers spin up agnostic of runtime.

---

## Phase 6: User Story 4 - Environment-Aware Dynamic Behavior (Priority: P2)

**Goal**: Deployments dynamically adjust configurations/constraints natively via runtime `node_tags` (`host`, `container`, `dev`, `prod`, `open`, `restricted`).
**Independent Test**: Send identical playbook to `prod`/`restricted` mapped node vs `dev` mapped node and verify appropriate security initializations trigger vs skip.

### Implementation for User Story 4

- [x] T021 [P] [US4] Configure global assertions in the `bootstrap.yml` orchestrator checking `node_tags` limits (e.g., stopping intersecting `dev` and `prod`).
- [x] T022 [US4] Inject `when: "'restricted' in node_tags"` conditionals within critical execution boundary roles.
- [x] T023 [US4] Provide baseline app templates taking advantage of contextual configuration.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T024 [P] Verify 100% Fully Qualified Collection Name (FQCN) compliance using `ansible-lint`.
- [x] T025 [P] Audit all tasks across the 14 directories for absolute idempotency (mandatory `changed_when`/`failed_when` parameters on ad-hoc shell runs).
- [x] T026 Update `/docs` and repo README referencing the Four-Layer Architecture Map and App API Contract.
- [x] T027 Validate Quickstart deployment run against the Local Docker Compose test targets per `SC-001` and `SC-002`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Base repo actions initialized.
- **Foundational (Phase 2)**: Core framework directories generated, blocking everything else.
- **User Stories (Phase 3+)**: Sequential or parallel based on Developer staffing. US1 (OS/facts loader) ideally precedes US2 (Package loader). US3 (Container loader) can happen concurrently.
- **Polish (Final Phase)**: Blocks release. Absolute idempotency and FQCN checks happen here.

### Parallel Opportunities

- The creation of the 14 structural directories and subcomponents can be dispersed largely across multiple sessions concurrently marking `[P]`.
- Implementations of the respective 38+ `package_loaders` (Apt vs. Pip vs. MAS) (T012, T013, T014) can run exclusively in parallel.
