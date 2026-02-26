# Data Model: ULS Framework

## Entities

### 1. `node_tags` Array

Defines the execution context constraints.

- **Type**: `list[string]`
- **Valid Values**: `host`, `container`, `dev`, `test`, `prod`, `open`, `restricted`
- **Validation**: Cannot be empty. The intersection of `dev` and `prod` on the same node should trigger a warning.

### 2. `package_loader` Payload

The structure for routing package installations.

```yaml
packages:
  - name: "nginx"
    type: "os" # Handled by apt/dnf/apk
  - name: "requests"
    type: "pip" # Handled by Python pip
  - name: "curl"
    type: "mas:" # macOS App Store specific
```

- **Validation**: MUST contain `name` and `type` fields for each dependency request.

### 3. Application Definition (App API Layer)

The standardized input used by all 81+ app roles.

```yaml
app_config:
  name: "redis"
  version: "latest"
  runtime: "container" # or "native"
  volumes: []
  ports:
    - "6379:6379"
```

- **Relationships**: If `runtime == container`, routes to `container_loader`. If `runtime == native`, routes to `package_loader`.
