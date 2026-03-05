#!/usr/bin/env python3
import os
import re
import sys

# Paths
REPO_ROOT = "/Users/snowdream/Workspace/Uniloader"
OS_REF_PATH = os.path.join(REPO_ROOT, "docs/OS_REFERENCE.md")
CI_TEMPLATE_PATH = os.path.join(REPO_ROOT, ".github/workflows/ci.yml")
WORKFLOWS_DIR = os.path.join(REPO_ROOT, ".github/workflows")

# 1. Read OS Reference to extract valid Linux OSes
allowed_families = [
    "RedHat",
    "Debian",
    "Alpine",
    "Suse",
    "Archlinux",
    "Mandrake",
    "Altlinux",
    "Void",
    "ClearLinux",
    "Solus",
    "OpenWrt",
    "Linux",
]

# Provide careful mappings for OSes to their actual docker images
DOCKER_MAPPINGS = {
    "amazon": "amazonlinux:latest",
    "rocky": "rockylinux:9",
    "rockylinux": "rockylinux:9",
    "almalinux": "almalinux:9",
    "oraclelinux": "oraclelinux:9",
    "opensuseleap": "opensuse/leap:latest",
    "opensusetumbleweed": "opensuse/tumbleweed:latest",
    "kali": "kalilinux/kali-rolling:latest",
    "void": "ghcr.io/void-linux/void-linux:latest",
    "clearlinux": "clearlinux:latest",
    "trixie": "debian:trixie",
    "bookworm": "debian:bookworm",
    "bullseye": "debian:bullseye",
    "buster": "debian:buster",
    "noble": "ubuntu:24.04",
    "jammy": "ubuntu:22.04",
    "focal": "ubuntu:20.04",
    "bionic": "ubuntu:18.04",
    "centos": "centos:stream9",
    "alpine": "alpine:latest",
    "debian": "debian:latest",
    "ubuntu": "ubuntu:latest",
    "fedora": "fedora:latest",
    "archlinux": "archlinux:latest",
}

os_list = set()

try:
    with open(OS_REF_PATH, "r") as f:
        for line in f:
            if not line.startswith("|"):
                continue
            parts = [p.strip() for p in line.split("|")]
            if len(parts) < 3:
                continue

            family_raw = parts[1].replace("**", "")
            # Handle versioned families like "Debian 12" by taking the first word
            family_base = family_raw.split()[0] if family_raw else ""
            if family_base not in allowed_families:
                continue

            distro_raw = parts[2].replace("`", "")
            # Some entries have multiple names like "Kylin / KylinOS", split them
            for d in map(str.strip, distro_raw.split("/")):
                # Skip generic names or names with spaces that aren't good docker images
                d_clean = d.lower().replace(" ", "")

                # Exclude specific version names for Debian/Ubuntu (we only want the latest generic ones)
                excluded_versions = [
                    "trixie",
                    "bookworm",
                    "bullseye",
                    "buster",
                    "noble",
                    "jammy",
                    "focal",
                    "bionic",
                ]
                if d_clean in excluded_versions:
                    continue

                # We strictly exclude overly generic ones
                if d_clean and d_clean not in ["linux", "redhat", "suse"]:
                    os_list.add(d_clean)
except Exception as e:
    print(f"Error reading OS Reference: {e}")
    sys.exit(1)

# Ensure essential base latest images are explicitly included
os_list.add("alpine")
os_list.add("debian")
os_list.add("ubuntu")
os_list = sorted(list(os_list))

print(f"Found {len(os_list)} valid OS targets for CI generation.")

# 2. Read CI Template
try:
    with open(CI_TEMPLATE_PATH, "r") as f:
        ci_template = f.read()
except Exception as e:
    print(f"Error reading CI template: {e}")
    sys.exit(1)

# 3. Generate individual YAML files
generated_count = 0
for os_name in os_list:
    # Skip ci.yml itself just in case
    if os_name == "ci":
        continue

    workflow_content = ci_template

    # Modify Name
    workflow_content = workflow_content.replace("name: CI", f"name: CI ({os_name.capitalize()})")

    # We need to modify the integration test step to run a specific container and test against it.
    # The current ci.yml says:
    #  docker compose up -d
    #  ansible-playbook -i inventory/docker.yml playbooks/test.yml
    # We will replace this with spinning up a basic container of that OS.
    docker_image = DOCKER_MAPPINGS.get(os_name, os_name)

    test_step_replacement = (
        f"      - name: Start Docker Container for {os_name}\n"
        f"        run: |\n"
        f"          # Try to pull and run the image, if it fails, the workflow just fails\n"
        f"          # (which is expected for unsupported ones natively)\n"
        f"          docker run -d --name uls_{os_name} --privileged {docker_image} \\\n"
        f'            sleep 86400 || echo "WARNING: Image {docker_image} not found or failed to start."\n\n'
        f"          # Create a dynamic inventory file for this run\n"
        f"          cat << 'INV' > inventory/dynamic_docker.yml\n"
        f"          all:\n"
        f"            vars:\n"
        f"              become_enabled: false\n"
        f"            hosts:\n"
        f"              {os_name}:\n"
        f"                ansible_host: uls_{os_name}\n"
        f'                ansible_connection: "docker"\n'
        f'                node_tags: ["open", "container", "docker_container"]\n'
        f"          INV\n\n"
        f"      - name: Run ansible-playbook test\n"
        f"        run: |\n"
        f"          source .venv/bin/activate\n"
        f"          ansible-playbook -i inventory/dynamic_docker.yml playbooks/test.yml\n\n"
        f"      - name: Cleanup Docker Containers\n"
        f"        if: always()\n"
        f"        run: |\n"
        f"          docker rm -f uls_{os_name} || true\n"
    )

    # Replace the existing Docker start/test/cleanup block
    # This regex looks for the 'Start Docker Containers' step and everything after it until the end.
    workflow_content = re.sub(
        r"      - name: Start Docker Containers.*Cleanup Docker Containers\n.*docker compose down\n",
        test_step_replacement,
        workflow_content,
        flags=re.DOTALL,
    )

    out_file = os.path.join(WORKFLOWS_DIR, f"{os_name}.yml")
    with open(out_file, "w") as f:
        f.write(workflow_content)
    generated_count += 1

print(f"Successfully generated {generated_count} CI workflows in .github/workflows/")
