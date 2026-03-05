# Ansible OS Facts Reference

This document provides a comprehensive mapping between `ansible_os_family` and `ansible_distribution` for mainstream operating systems, covering global top-tier distributions, netboot.xyz, and major Chinese enterprise providers (信创).

## 1. Comprehensive OS Family Mapping Table

| OS Family (`ansible_os_family`) | Distribution (`ansible_distribution`) | Common Package Manager | Notes / Description                   |
| :------------------------------ | :------------------------------------ | :--------------------- | :------------------------------------ |
| **RedHat**                      | `RedHat`                              | `dnf` / `yum`          | Red Hat Enterprise Linux (RHEL)       |
| **RedHat**                      | `CentOS`                              | `dnf` / `yum`          | CentOS Linux / CentOS Stream          |
| **RedHat**                      | `Rocky`                               | `dnf`                  | Rocky Linux (RHEL Compatible)         |
| **RedHat**                      | `AlmaLinux`                           | `dnf`                  | AlmaLinux (RHEL Compatible)           |
| **RedHat**                      | `OracleLinux`                         | `dnf` / `yum`          | Oracle Linux (RHEL Derivative)        |
| **RedHat**                      | `Fedora`                              | `dnf`                  | Fedora Linux                          |
| **RedHat**                      | `Fedora CoreOS`                       | `rpm-ostree`           | Immutable Container Host              |
| **RedHat**                      | `Nobara`                              | `dnf`                  | Gaming-optimized Fedora               |
| **RedHat**                      | `Amazon`                              | `dnf` / `yum`          | Amazon Linux 1, 2, and 2023           |
| **RedHat**                      | `OpenEuler`                           | `dnf` / `yum`          | Huawei openEuler                      |
| **RedHat**                      | `EulerOS`                             | `yum` / `dnf`          | Huawei EulerOS (Commercial)           |
| **RedHat**                      | `Anolis`                              | `dnf` / `yum`          | Alibaba Anolis OS                     |
| **RedHat**                      | `TencentOS`                           | `yum` / `dnf`          | TencentOS Server                      |
| **RedHat**                      | `OpenCloudOS`                         | `dnf` / `yum`          | OpenCloudOS (Tencent Community)       |
| **RedHat**                      | `BaiduOS`                             | `yum`                  | Baidu internal Linux                  |
| **RedHat**                      | `NeoKylin`                            | `yum` / `dnf`          | NeoKylin                              |
| **RedHat**                      | `Kylin Linux Advanced Server`         | `dnf`                  | Kylin V10 Server                      |
| **RedHat**                      | `KylinSec`                            | `dnf`                  | KylinSec                              |
| **RedHat**                      | `EuroLinux`                           | `dnf`                  | Polish RHEL derivative                |
| **Debian**                      | `Debian`                              | `apt`                  | The Universal Operating System        |
| **Debian**                      | `Ubuntu`                              | `apt`                  | Canonical Ubuntu                      |
| **Debian**                      | `MX Linux`                            | `apt`                  | Most popular Desktop (DistroWatch #1) |
| **Debian**                      | `antiX`                               | `apt`                  | Independent/Debian lightweight        |
| **Debian**                      | `Kali`                                | `apt`                  | Security Research & PenTesting        |
| **Debian**                      | `Kylin` / `KylinOS`                   | `apt`                  | KylinOS V10 (Desktop/Generic)         |
| **Debian**                      | `openKylin`                           | `apt`                  | openKylin community                   |
| **Debian**                      | `UOS`                                 | `apt`                  | UnionTech OS                          |
| **Debian**                      | `Deepin`                              | `apt`                  | Deepin Linux                          |
| **Debian**                      | `Linx`                                | `apt`                  | Linx OS (High Security)               |
| **Debian**                      | `Mint`                                | `apt`                  | Linux Mint                            |
| **Debian**                      | `Pop!_OS`                             | `apt`                  | Pop!\_OS by System76                  |
| **Debian**                      | `Raspbian`                            | `apt`                  | Raspberry Pi OS                       |
| **Debian**                      | `Zorin`                               | `apt`                  | Zorin OS (Windows-migrant friendly)   |
| **Debian**                      | `Proxmox`                             | `apt`                  | Proxmox VE Virt Host                  |
| **Debian**                      | `VyOS`                                | `apt`                  | Network OS based on Debian            |
| **Debian**                      | `TrueNAS`                             | `apt`                  | TrueNAS SCALE (Storage)               |
| **Debian**                      | `Vanilla`                             | `apt`                  | Vanilla OS (Immutable)                |
| **Debian**                      | `Grml`                                | `apt`                  | Debian-based Live system              |
| **Alpine**                      | `Alpine`                              | `apk`                  | Ultra-lightweight Linux               |
| **Suse**                        | `SLES`                                | `zypper`               | SUSE Linux Enterprise Server          |
| **Suse**                        | `openSUSE`                            | `zypper`               | openSUSE Leap / Tumbleweed            |
| **Suse**                        | `Harvester`                           | `zypper`               | SUSE Hyperconverged (HCI)             |
| **Archlinux**                   | `Archlinux`                           | `pacman`               | Arch Linux                            |
| **Archlinux**                   | `Manjaro`                             | `pacman`               | Manjaro Linux                         |
| **Archlinux**                   | `EndeavourOS`                         | `pacman`               | EndeavourOS                           |
| **Archlinux**                   | `CachyOS`                             | `pacman`               | performance-optimized Arch            |
| **Archlinux**                   | `SteamOS`                             | `pacman`               | Valve SteamOS                         |
| **Gentoo**                      | `Gentoo`                              | `emerge`               | Gentoo Linux                          |
| **Mandrake**                    | `Mageia`                              | `dnf` / `urpmi`        | Mageia Linux                          |
| **Mandrake**                    | `OpenMandriva`                        | `dnf`                  | OpenMandriva Lx                       |
| **Mandrake**                    | `PCLinuxOS`                           | `apt-rpm`              | PCLinuxOS                             |
| **Altlinux**                    | `Altlinux`                            | `apt-rpm`              | ALT Linux                             |
| **Slackware**                   | `Slackware`                           | `slackpkg`             | Slackware Linux                       |
| **Flatcar**                     | `Flatcar`                             | `emerge` (int)         | Immutable Container Host              |
| **NixOS**                       | `NixOS`                               | `nix`                  | Functional, declarative Linux         |
| **Void**                        | `Void`                                | `xbps`                 | Void Linux (runit-based)              |
| **ClearLinux**                  | `Clear`                               | `swupd`                | Intel performance-oriented OS         |
| **ClearLinux**                  | `Clear Linux OS`                      | `swupd`                | Intel Clear Linux                     |
| **ClearLinux**                  | `Clear Linux Mix`                     | `swupd`                | Clear Linux Custom Mix                |
| **Solus**                       | `Solus`                               | `eopkg`                | Independent desktop distro            |
| **OpenWrt**                     | `OpenWrt`                             | `opkg`                 | Embedded/Network Devices              |
| **Linux**                       | `Talos`                               | `talosctl`             | API-driven Kubernetes OS              |
| **Darwin**                      | `MacOSX`                              | `brew` (ext)           | Apple macOS                           |
| **FreeBSD**                     | `FreeBSD`                             | `pkg`                  | FreeBSD                               |
| **OpenBSD**                     | `OpenBSD`                             | `pkg_add`              | OpenBSD                               |
| **NetBSD**                      | `NetBSD`                              | `pkgin`                | NetBSD                                |
| **BSD**                         | `GhostBSD`                            | `pkg`                  | Desktop FreeBSD                       |
| **DragonFly**                   | `DragonFlyBSD` / `DragonflyBSD`       | `pkg`                  | DragonFly BSD                         |
| **DragonFly**                   | `Gentoo/DragonFlyBSD`                 | `emerge`               | DragonFly BSD (Gentoo Prefix)         |
| **Solaris**                     | `Solaris` / `SunOS`                   | `pkg`                  | Solaris                               |
| **Solaris**                     | `SmartOS`                             | `pkgin`                | Illumos distribution                  |
| **Solaris**                     | `OmniOS` / `OpenIndiana`              | `pkg`                  | Illumos distributions                 |
| **Solaris**                     | `Nexenta`                             | `apt-get`              | Illumos distribution                  |
| **AIX**                         | `AIX`                                 | `installp` / `rpm`     | IBM AIX                               |
| **HP-UX**                       | `HPUX`                                | `swinstall`            | HP-UX                                 |
| **Debian**                      | `Neon` / `KDE neon`                   | `apt`                  | KDE Neon                              |
| **Debian**                      | `Parrot`                              | `apt`                  | Parrot Security OS                    |
| **Debian**                      | `Devuan`                              | `apt`                  | Systemd-free Debian                   |
| **Debian**                      | `Cumulus Linux`                       | `apt`                  | Network Switch OS                     |
| **RedHat**                      | `CloudLinux`                          | `yum` / `dnf`          | Shared Hosting OS                     |
| **RedHat**                      | `Scientific` / `SLC`                  | `yum`                  | Scientific Linux                      |
| **RedHat**                      | `Virtuozzo`                           | `yum`                  | Virtuozzo Linux                       |
| **RedHat**                      | `XenServer`                           | `yum`                  | Citrix XenServer                      |
| **RedHat**                      | `Ovs` / `OEL`                         | `yum`                  | Oracle VM Server                      |
| **RedHat**                      | `Ascendos`                            | `yum`                  | Ascendos Enterprise Linux             |
| **RedHat**                      | `PSBM`                                | `yum`                  | Parallels Server Bare Metal           |
| **RedHat**                      | `MIRACLE`                             | `yum` / `dnf`          | MIRACLE LINUX                         |
| **RedHat**                      | `Alibaba`                             | `yum` / `dnf`          | Alibaba Cloud Linux                   |
| **Debian**                      | `Pardus GNU/Linux`                    | `apt`                  | Turkish National OS                   |
| **Debian**                      | `OSMC`                                | `apt`                  | Open Source Media Center              |
| **Debian**                      | `Univention Corporate Server`         | `apt`                  | Univention (UCS)                      |
| **Debian**                      | `Linux Mint Debian Edition`           | `apt`                  | LMDE                                  |
| **Suse**                        | `SLED`                                | `zypper`               | SUSE Linux Enterprise Desktop         |
| **Suse**                        | `SLES_SAP`                            | `zypper`               | SUSE for SAP Applications             |
| **Suse**                        | `ALP-Dolomite`                        | `zypper`               | SUSE Adaptable Linux Platform         |
| **Suse**                        | `SL-Micro`                            | `zypper`               | SUSE Linux Micro                      |
| **Suse**                        | `openSUSE MicroOS`                    | `zypper`               | Immutable openSUSE                    |
| **Archlinux**                   | `Antergos`                            | `pacman`               | Discontinued Arch derivative          |
| **Mandrake**                    | `Mandriva`                            | `urpmi`                | Mandriva Linux                        |
| **Gentoo**                      | `Funtoo`                              | `emerge`               | Gentoo variant                        |
| **BSD**                         | `TrueOS`                              | `pkg`                  | Discontinued FreeBSD distro           |
| **SMGL**                        | `SMGL`                                | `cast`                 | Source Mage GNU/Linux                 |
| **Windows**                     | `Windows`                             | `powershell`           | Windows (via WinRM/SSH)               |

## 2. Release Codename Reference (Major Distros)

Crucial for repository management (`sources.list` or `yum_repository`).

### Debian / Ubuntu

| Version          | Codename   | Family | Release Date  |
| :--------------- | :--------- | :----- | :------------ |
| **Debian 13**    | `trixie`   | Debian | TBD (Testing) |
| **Debian 12**    | `bookworm` | Debian | 2023          |
| **Debian 11**    | `bullseye` | Debian | 2021          |
| **Debian 10**    | `buster`   | Debian | 2019          |
| **Ubuntu 24.04** | `noble`    | Debian | 2024          |
| **Ubuntu 22.04** | `jammy`    | Debian | 2022          |
| **Ubuntu 20.04** | `focal`    | Debian | 2020          |

### RHEL / CentOS Generation

| RHEL Version | Based on Fedora | Kernel Basis | Note                      |
| :----------- | :-------------- | :----------- | :------------------------ |
| **RHEL 9**   | Fedora 34       | 5.14         | Rocky 9, Alma 9, Oracle 9 |
| **RHEL 8**   | Fedora 28       | 4.18         | Rocky 8, Alma 8, Oracle 8 |
| **RHEL 7**   | Fedora 19       | 3.10         | CentOS 7 (EOL 2024)       |

## 3. Expert Caveats

### 3.1 The Kylin Family Transformations

**Note**: Kylin systems may span completely different OS families depending on the edition.

- **Advanced Server Edition**: Typically identified as the `RedHat` family.
- **Desktop/Generic Edition**: Typically identified as the `Debian` family.

### 3.2 Immutable OS Implementations

For `Fedora CoreOS`, `Flatcar`, `Talos`, and `Vanilla OS`:

- Direct use of the standard Ansible `package` module is prohibited. Use containerized deployments or system-specific atomic update engines.

### 3.3 Architecture Fingerprinting

It is highly recommended to include system architecture variables when loading specific definitions (crucial for ARM/domestic CPU support):

```yaml
- include_vars: "{{ ansible_os_family }}-{{ ansible_architecture }}.yml"
# Result: Debian-aarch64.yml or RedHat-x86_64.yml
```

## 4. Network Operating Systems (NOS)

Ansible is heavily used for network automation. For these platforms, OS identification typically uses `ansible_network_os` instead of `ansible_os_family`.

| Platform / Vendor      | `ansible_network_os`          | Connection Type           | Description                       |
| :--------------------- | :---------------------------- | :------------------------ | :-------------------------------- |
| **Cisco IOS / IOS-XE** | `cisco.ios.ios`               | `network_cli`             | Cisco Routers & Switches          |
| **Cisco NX-OS**        | `cisco.nxos.nxos`             | `network_cli` / `httpapi` | Cisco Nexus Switches              |
| **Cisco IOS-XR**       | `cisco.iosxr.iosxr`           | `network_cli`             | Cisco Service Provider Routers    |
| **Juniper**            | `junipernetworks.junos.junos` | `netconf` / `network_cli` | Junos OS (QFX, EX, SRX, MX)       |
| **Arista**             | `arista.eos.eos`              | `network_cli` / `httpapi` | Arista EOS Switches               |
| **F5 Networks**        | `f5networks.f5_modules.tmsh`  | `httpapi`                 | F5 BIG-IP Load Balancers          |
| **Palo Alto**          | `paloaltonetworks.panos`      | `httpapi`                 | PAN-OS Firewalls                  |
| **Fortinet**           | `fortinet.fortios.fortios`    | `httpapi`                 | FortiOS Firewalls                 |
| **MikroTik**           | `community.routeros.routeros` | `network_cli`             | MikroTik RouterOS                 |
| **VyOS**               | `vyos.vyos.vyos`              | `network_cli`             | Open Source Router (Debian based) |

## 5. Specialized Infrastructure & Hypervisors

Some highly specialized enterprise environments rely on custom connection plugins or represent unique target OS architectures:

| Environment          | Supported Via                    | Notes                                                  |
| :------------------- | :------------------------------- | :----------------------------------------------------- |
| **VMware ESXi**      | `vmware_guest` / `esxi_hostname` | Managed via vCenter/ESXi APIs, not standard SSH.       |
| **IBM i (AS/400)**   | `ibm.power_ibmi` collection      | Managed via SSH but uses PASE environment.             |
| **OpenVMS**          | `community.general`              | Very legacy/niche, requires specific python SSH setup. |
| **z/OS (Mainframe)** | `ibm.ibm_zos_core`               | IBM Z mainframes.                                      |

## 6. Debug Command

Run this to see exactly how Ansible identifies your current host:

```bash
ansible all -m setup -a 'filter=ansible_distribution*'

# OR specific facts:

ansible all -m setup | grep -E "ansible_os_family|ansible_distribution|ansible_architecture"
```
