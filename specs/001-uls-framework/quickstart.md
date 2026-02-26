# Quickstart: Testing the ULS Framework

This document outlines how an engineer can bootstrap the Local Docker Compose environment to validate the Four-Layer Architecture and Idempotency guarantees.

## Prerequisite Setup

Ensure your local machine has initialized Docker and Compose capability:

```bash
docker --version
docker compose version
```

## Running the Core Automated Scenarios

### Step 1: Bootstrap the Test Target Containers

The included test matrix provisions sterile environments mimicking Alpine, Debian, and RHEL.

```bash
# Execute within the repository root
docker compose up -d
```

### Step 2: Provision Framework (Run 1)

Execute the foundation and application deployer. During this run, packages will be downloaded, runtimes established, and state changed.

```bash
ansible-playbook -i tests/inventory.yml playbooks/orchestrator.yml
```

_Expected Result_: High number of `changed` statuses representing successful installation.

### Step 3: Verify Absolute Idempotency (Run 2)

Execute the precise identical command to validate the ULS Constitution requirements.

```bash
ansible-playbook -i tests/inventory.yml playbooks/orchestrator.yml
```

_Expected Result_: **Exactly 0 changed tasks**, indicating all tasks properly detect state.

## Verifying FQCN Compliance

Validate adherence to the Fully Qualified Collection Name guidelines using ansible-lint.

```bash
ansible-lint roles/ playbooks/
```

_Expected Result_: Clean output with 0 FQCN violations.
