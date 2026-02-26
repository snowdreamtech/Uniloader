# Contracts: Application API Layer

This document defines the schema and contract for invoking application roles via the `app` API layer within the ULS framework.

## Contract 1: `role: app/[app_name]`

All 81+ application roles strictly adhere to this input signature to ensure predictability and abstraction.

### Endpoint / Execution Goal

Configure and deploy a generic or specific application transparently parsing the environment boundaries.

### Input Parameters (Variables)

| Variable      | Type   | Required | Description                                                     |
| ------------- | ------ | -------- | --------------------------------------------------------------- |
| `app_runtime` | Enum   | Optional | Override the default runtime (`native` or `container`).         |
| `app_version` | String | Optional | The targeted software version (defaults to `latest`).           |
| `app_ports`   | List   | Optional | Target port bindings (e.g., `["8080:80"]`).                     |
| `app_volumes` | List   | Optional | Required volume mappings (e.g., `["/opt/data:/var/lib/data"]`). |
| `deploy_mode` | Enum   | Optional | e.g., `server`, `desktop`, `bootstrap`, `dev`.                  |

### Outputs / Side-Effects

- The target software is installed and activated.
- If `app_runtime == container`, a container matches the port/volume mapping.
- If `app_runtime == native`, systemd/OS service equivalents are configured and enabled.

### Expected Behavior

- **Idempotency**: Running the role sequentially 10 times will result in exactly `1` initial change (if not already present), and `0` changes across the remaining 9 runs.
- **Dynamic Routing**: The application layer should NOT include native package manager logic (e.g., `apt update`), but rather route dependencies upstream to `package_loader`.
