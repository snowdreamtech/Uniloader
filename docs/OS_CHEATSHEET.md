# ULS OS & Package Manager Cheatsheet

This cheatsheet is condensed from the complete `OS_REFERENCE.md`. It provides a core reference for developers writing Ansible Roles, helping you quickly map `ansible_os_family` to its corresponding package manager.

## 1. Core Mapping Table: OS Family -> Package Manager

| OS Family (`ansible_os_family`) | Default Package Manager     | Applicable Scope / Note                                                                                 |
| :------------------------------ | :-------------------------- | :------------------------------------------------------------------------------------------------------ |
| **RedHat**                      | `dnf` / `yum`               | RHEL, CentOS, Fedora, Amazon, and most domestic server OS (openEuler, Anolis, TencentOS, Kylin Server). |
| **Debian**                      | `apt`                       | Debian, Ubuntu, Linux Mint, and some domestic desktop OS (UOS, Deepin, Kylin Desktop).                  |
| **Alpine**                      | `apk`                       | Ultra-lightweight Linux (commonly used as container bases).                                             |
| **Suse**                        | `zypper`                    | SLES, openSUSE, and related micro variants.                                                             |
| **Archlinux**                   | `pacman`                    | Arch and its derivatives (Manjaro, etc.).                                                               |
| **Mandrake** / **Altlinux**     | `dnf` / `urpmi` / `apt-rpm` | Niche branches like Mageia, PCLinuxOS, ALT Linux.                                                       |
| **Gentoo** / **Flatcar**        | `emerge`                    | Gentoo and derivatives (Note: Flatcar is an immutable system).                                          |
| **NixOS**                       | `nix`                       | Declarative, functional Linux.                                                                          |
| **Void**                        | `xbps`                      | Void Linux.                                                                                             |
| **Solus**                       | `eopkg`                     | Solus OS.                                                                                               |
| **OpenWrt**                     | `opkg`                      | Embedded and router firmware environments.                                                              |
| **Linux**                       | `talosctl`                  | Specifically Talos (API-driven Kubernetes OS).                                                          |
| **Darwin**                      | `brew` / `port` (External)  | Apple macOS (Not native; requires Homebrew or MacPorts).                                                |
| **FreeBSD** / **BSD**, etc.     | `pkg` / `pkg_add` / `pkgin` | Various BSD branches (FreeBSD, OpenBSD, NetBSD, etc.).                                                  |
| **Solaris**                     | `pkg` / `pkgin` / `apt-get` | Oracle Solaris and Illumos-derived storage systems.                                                     |
| **AIX**                         | `installp` / `rpm`          | IBM AIX environments.                                                                                   |
| **HP-UX**                       | `swinstall`                 | HP-UX environments.                                                                                     |
| **Windows**                     | `powershell`                | Windows Server / Desktop.                                                                               |
| _(Network OS)_                  | `network_cli` / `httpapi`   | Cisco, Juniper, Huawei, etc., network switches/routers (accessed via `ansible_network_os`).             |

---

## 2. Toolchain Reference: Package Manager Support Matrix

When writing Roles and needing specific Ansible modules, use this matrix to reverse-lookup supported OS families.

| Ansible Module                                                      | Covered OS Families        |
| :------------------------------------------------------------------ | :------------------------- |
| **`ansible.builtin.apt`**                                           | Debian                     |
| **`ansible.builtin.dnf`** / **`yum`**                               | RedHat, Mandrake (Partial) |
| **`community.general.apk`**                                         | Alpine                     |
| **`community.general.zypper`**                                      | Suse                       |
| **`community.general.pacman`**                                      | Archlinux                  |
| **`community.general.pkgng`**                                       | FreeBSD, DragonFly, BSD    |
| **`community.general.homebrew`** / **`community.general.macports`** | Darwin (macOS)             |

> **Tip**: In the ULS framework, we seamlessly route across these package managers via `package_loader`. You do not need to call `apt` or `dnf` directly; simply issue unified instructions to the `packages` dictionary.

---

## 3. ⚠️ Development Pitfalls and Exceptions (Highly Important)

### 3.1 The Dual-Line Architecture of Domestic Chinese OS

The most classic examples are **Kylin** and certain commercial distributions. Because these systems cater to both "government desktop" and "enterprise server" lines simultaneously, different editions of the _same_ OS have functionally split underpinnings:

- **Server Edition (e.g., Kylin Linux Advanced Server)**
  - Rebuilt from CentOS/RHEL source code.
  - Ansible identifies it as the **`RedHat`** family.
  - Package manager is **`dnf` / `yum`**.
- **Desktop/Generic Edition (e.g., KylinOS V10, openKylin)**
  - Rebuilt from Ubuntu/Debian source code.
  - Ansible identifies it as the **`Debian`** family.
  - Package manager is **`apt`**.

👉 **Development Strategy**: Never hardcode `ansible_distribution == 'Kylin'` in playbooks to guess between apt or yum. **Always rely strictly on `ansible_os_family` for branching logic.**

### 3.2 The Immutable OS Installation Nightmare

Several modern container host OSes (e.g., `Fedora CoreOS`, `Flatcar`, `Vanilla OS`, `Talos`) feature a read-only root file system.

- **Do not** attempt to use standard Ansible modules like `package`, `apt`, or `dnf` to install software directly. This will fail outright due to the locked system state.
- 👉 **Development Strategy**: On these systems, all additional dependencies must be handled either by **pulling containers (Docker/Podman)** or using their exclusive atomic tree CLI commands (like `rpm-ostree`).

### 3.3 Architecture Split Mapping

When dealing with domestic enterprise environments, you will frequently encounter a mix of x86 architectures (Intel/AMD) and ARM architectures (Kunpeng, Phytium).

- 👉 **Development Strategy**: When loading external variable configurations, append the architecture suffix to the family name:

  ```yaml
  - include_vars: "{{ ansible_os_family }}-{{ ansible_architecture }}.yml"
  # Correctly loads `RedHat-x86_64.yml` or `RedHat-aarch64.yml`
  ```
