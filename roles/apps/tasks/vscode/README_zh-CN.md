# Visual Studio Code

用于跨平台部署的 Visual Studio Code (VS Code) 应用程序角色。

## 设计与架构

### 概述

本角色为 Windows、macOS 和 Linux（Debian/RHEL）提供了统一的 VS Code 安装接口。它能够处理特定于架构的逻辑（x64 与 ARM），并优先选用原生软件包仓库进行安装。

### 架构图

```text
[app 角色] -> [vscode/native/default.yml]
                  |
                  +-> [debian.yml] (Apt/仓库)
                  +-> [redhat.yml] (Yum/仓库)
                  +-> [darwin.yml] (Brew Cask)
                  +-> [windows.yml] (Winget)
                  +-> [extensions.yml] (插件安装)
```

### 设计原则

1. **可审计 (Auditable)**: 通过 `log_loader` 进行完整日志记录。
2. **可覆盖 (Overridable)**: 使用 `vscode_extensions` 自定义插件安装。
3. **可扩展 (Extensible)**: 可在 `native/` 目录下添加新平台支持。
4. **极致精简 (Lean)**: 仅在软件包安装成功后才执行后续逻辑。

## 使用说明

### 变量参考

| 变量 | 说明 | 默认值 |
| :--- | :--- | :--- |
| `vscode_extensions` | 要安装的插件列表 | `[]` |
| `vscode_channel` | 安装渠道 (stable/insiders) | `stable` |

### 使用示例

#### 基础安装

```yaml
- ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "vscode"
```

#### 高级安装（包含插件）

```yaml
- ansible.builtin.include_role:
    name: "app"
  vars:
    app_name: "vscode"
    vscode_extensions:
      - "ms-python.python"
      - "golang.go"
      - "eamodio.gitlens"
```

## 运维指南

### 部署前检查清单

- 确保 `context` 角色已运行，以填充 `os_fingerprint` 和 `ansible_architecture`。
- 对于 Linux，确保可以访问 `packages.microsoft.com`。

### 故障排查

- **架构不匹配**: 检查 `ansible_architecture` 是否正确获取。
- **插件安装失败**: 验证 VS Code 是否安装成功且 `code` 命令在 `PATH` 中。

## 安全说明

- 使用微软官方签名仓库（GPG 验证）。
- 插件在用户上下文中安装。

## 开发指引

新的安装方法或特定于平台的逻辑应放置在 `roles/apps/tasks/vscode/native/` 目录下。
